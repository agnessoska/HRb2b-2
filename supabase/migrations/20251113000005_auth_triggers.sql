-- ============================================================================
-- AUTH TRIGGERS MIGRATION
-- Creates triggers for automatic profile creation after user registration
-- ============================================================================

-- ============================================================================
-- FUNCTION: Create HR specialist profile after registration
-- ============================================================================
CREATE OR REPLACE FUNCTION create_hr_profile()
RETURNS TRIGGER AS $$
DECLARE
  new_org_id UUID;
  user_role TEXT;
  user_full_name TEXT;
  user_org_name TEXT;
BEGIN
  -- Get user metadata
  user_role := NEW.raw_user_meta_data->>'role';
  user_full_name := NEW.raw_user_meta_data->>'full_name';
  user_org_name := NEW.raw_user_meta_data->>'organization_name';

  -- Only proceed if user is HR specialist
  IF user_role = 'hr_specialist' THEN
    -- Create new organization
    INSERT INTO organizations (name, owner_id, token_balance)
    VALUES (user_org_name, NEW.id, 1000)
    RETURNING id INTO new_org_id;

    -- Create HR specialist profile
    INSERT INTO hr_specialists (
      user_id,
      organization_id,
      full_name,
      email,
      role
    ) VALUES (
      NEW.id,
      new_org_id,
      user_full_name,
      NEW.email,
      'owner'
    );

    RAISE NOTICE 'Created HR specialist profile for user % with organization %', NEW.id, new_org_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Create candidate profile after registration
-- ============================================================================
CREATE OR REPLACE FUNCTION create_candidate_profile()
RETURNS TRIGGER AS $$
DECLARE
  user_role TEXT;
  user_full_name TEXT;
BEGIN
  -- Get user metadata
  user_role := NEW.raw_user_meta_data->>'role';
  user_full_name := NEW.raw_user_meta_data->>'full_name';

  -- Only proceed if user is candidate
  IF user_role = 'candidate' THEN
    -- Create candidate profile
    INSERT INTO candidates (
      user_id,
      full_name,
      email,
      tests_completed,
      profile_completeness,
      is_public
    ) VALUES (
      NEW.id,
      user_full_name,
      NEW.email,
      0,
      20, -- Basic profile is 20% complete
      true
    );

    RAISE NOTICE 'Created candidate profile for user %', NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TRIGGER: Create profile after user registration
-- ============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created_hr ON auth.users;
CREATE TRIGGER on_auth_user_created_hr
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_hr_profile();

DROP TRIGGER IF EXISTS on_auth_user_created_candidate ON auth.users;
CREATE TRIGGER on_auth_user_created_candidate
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_candidate_profile();

-- ============================================================================
-- FUNCTION: Update profile completeness for candidates
-- ============================================================================
CREATE OR REPLACE FUNCTION calculate_profile_completeness(candidate_row candidates)
RETURNS INTEGER AS $$
DECLARE
  completeness INTEGER := 0;
BEGIN
  -- Full name, email (always present) = 20%
  completeness := 20;

  -- Phone = 10%
  IF candidate_row.phone IS NOT NULL AND candidate_row.phone != '' THEN
    completeness := completeness + 10;
  END IF;

  -- Category = 10%
  IF candidate_row.category_id IS NOT NULL THEN
    completeness := completeness + 10;
  END IF;

  -- Work experience = 15%
  IF candidate_row.work_experience IS NOT NULL AND candidate_row.work_experience != '' THEN
    completeness := completeness + 15;
  END IF;

  -- Education = 10%
  IF candidate_row.education IS NOT NULL AND candidate_row.education != '' THEN
    completeness := completeness + 10;
  END IF;

  -- About me = 10%
  IF candidate_row.about_me IS NOT NULL AND candidate_row.about_me != '' THEN
    completeness := completeness + 10;
  END IF;

  -- Tests completed = 25% (6 tests = 25%)
  IF candidate_row.tests_completed > 0 THEN
    completeness := completeness + (candidate_row.tests_completed * 4);
  END IF;

  -- Cap at 100%
  IF completeness > 100 THEN
    completeness := 100;
  END IF;

  RETURN completeness;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Auto-update profile completeness
-- ============================================================================
CREATE OR REPLACE FUNCTION update_candidate_completeness()
RETURNS TRIGGER AS $$
BEGIN
  NEW.profile_completeness := calculate_profile_completeness(NEW);
  NEW.profile_last_updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_candidate_update_completeness ON candidates;
CREATE TRIGGER on_candidate_update_completeness
  BEFORE UPDATE ON candidates
  FOR EACH ROW
  EXECUTE FUNCTION update_candidate_completeness();

-- ============================================================================
-- FUNCTION: Deduct tokens from organization
-- ============================================================================
CREATE OR REPLACE FUNCTION deduct_tokens(
  org_id UUID,
  amount INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
  current_balance INTEGER;
BEGIN
  -- Get current balance
  SELECT token_balance INTO current_balance
  FROM organizations
  WHERE id = org_id
  FOR UPDATE;

  -- Check if enough tokens
  IF current_balance < amount THEN
    RAISE EXCEPTION 'Insufficient token balance. Required: %, Available: %', amount, current_balance;
  END IF;

  -- Deduct tokens
  UPDATE organizations
  SET token_balance = token_balance - amount
  WHERE id = org_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION deduct_tokens IS 'Deduct tokens from organization balance with validation';

-- ============================================================================
-- FUNCTION: Add tokens to organization
-- ============================================================================
CREATE OR REPLACE FUNCTION add_tokens(
  org_id UUID,
  amount INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE organizations
  SET token_balance = token_balance + amount
  WHERE id = org_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION add_tokens IS 'Add tokens to organization balance';

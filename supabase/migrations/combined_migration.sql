-- ============================================================================
-- INITIAL SCHEMA MIGRATION
-- Creates core tables: organizations, hr_specialists, professional_categories
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: organizations
-- Organizations (companies, recruitment agencies)
-- ============================================================================
CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  logo_url TEXT,
  owner_id UUID,
  token_balance INTEGER DEFAULT 1000 CHECK (token_balance >= 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_organizations_owner ON organizations(owner_id);

COMMENT ON TABLE organizations IS 'Organizations that use the HR platform';
COMMENT ON COLUMN organizations.token_balance IS 'Token balance for AI operations and other paid features';

-- ============================================================================
-- TABLE: hr_specialists
-- HR specialists (linked to organizations)
-- ============================================================================
CREATE TABLE IF NOT EXISTS hr_specialists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('owner', 'member')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hr_specialists_user ON hr_specialists(user_id);
CREATE INDEX IF NOT EXISTS idx_hr_specialists_org ON hr_specialists(organization_id);
CREATE INDEX IF NOT EXISTS idx_hr_specialists_email ON hr_specialists(email);

COMMENT ON TABLE hr_specialists IS 'HR specialists who work for organizations';
COMMENT ON COLUMN hr_specialists.role IS 'Role in organization: owner or member';

-- ============================================================================
-- TABLE: professional_categories
-- Professional categories for candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS professional_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ru VARCHAR(255) NOT NULL,
  name_kk VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_professional_categories_name_ru ON professional_categories(name_ru);
CREATE INDEX IF NOT EXISTS idx_professional_categories_name_en ON professional_categories(name_en);

COMMENT ON TABLE professional_categories IS 'Professional categories in 3 languages (ru, kk, en)';

-- ============================================================================
-- INITIAL DATA: professional_categories
-- 13 categories in 3 languages
-- ============================================================================
INSERT INTO professional_categories (name_ru, name_kk, name_en) VALUES
  ('IT и технологии', 'IT және технологиялар', 'IT and Technology'),
  ('Маркетинг и реклама', 'Маркетинг және жарнама', 'Marketing and Advertising'),
  ('Продажи', 'Сату', 'Sales'),
  ('Финансы и бухгалтерия', 'Қаржы және бухгалтерия', 'Finance and Accounting'),
  ('Управление и менеджмент', 'Басқару және менеджмент', 'Management'),
  ('HR и рекрутинг', 'HR және жұмысқа орналастыру', 'HR and Recruitment'),
  ('Инженерия', 'Инженерия', 'Engineering'),
  ('Дизайн', 'Дизайн', 'Design'),
  ('Медицина', 'Медицина', 'Healthcare'),
  ('Образование', 'Білім беру', 'Education'),
  ('Логистика', 'Логистика', 'Logistics'),
  ('Производство', 'Өндіріс', 'Manufacturing'),
  ('Другое', 'Басқа', 'Other')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- TRIGGER: updated_at auto-update
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to organizations
CREATE TRIGGER update_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to hr_specialists
CREATE TRIGGER update_hr_specialists_updated_at
  BEFORE UPDATE ON hr_specialists
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
-- ============================================================================
-- CANDIDATES SCHEMA MIGRATION
-- Creates tables: candidates, candidate_skills, skills_dictionary
-- ============================================================================

-- ============================================================================
-- TABLE: candidates
-- Job seekers (candidates)
-- ============================================================================
CREATE TABLE IF NOT EXISTS candidates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  category_id UUID REFERENCES professional_categories(id),
  work_experience TEXT,
  education TEXT,
  about_me TEXT,

  -- Statistics
  tests_completed INTEGER DEFAULT 0 CHECK (tests_completed >= 0 AND tests_completed <= 6),
  profile_completeness INTEGER DEFAULT 0 CHECK (profile_completeness >= 0 AND profile_completeness <= 100),

  -- Visibility settings
  is_public BOOLEAN DEFAULT true,

  -- Timestamps
  profile_last_updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_candidates_user ON candidates(user_id);
CREATE INDEX IF NOT EXISTS idx_candidates_category ON candidates(category_id);
CREATE INDEX IF NOT EXISTS idx_candidates_email ON candidates(email);
CREATE INDEX IF NOT EXISTS idx_candidates_public ON candidates(is_public) WHERE is_public = true;
CREATE INDEX IF NOT EXISTS idx_candidates_tests ON candidates(tests_completed);

COMMENT ON TABLE candidates IS 'Job seekers who register on the platform';
COMMENT ON COLUMN candidates.is_public IS 'Whether candidate is visible in Talent Market';
COMMENT ON COLUMN candidates.tests_completed IS 'Number of completed psychometric tests (0-6)';
COMMENT ON COLUMN candidates.profile_completeness IS 'Profile completion percentage (0-100)';

-- ============================================================================
-- TABLE: skills_dictionary
-- Skills dictionary with synonyms and translations
-- ============================================================================
CREATE TABLE IF NOT EXISTS skills_dictionary (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  canonical_name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(name)
);

CREATE INDEX IF NOT EXISTS idx_skills_dict_name ON skills_dictionary(name);
CREATE INDEX IF NOT EXISTS idx_skills_dict_canonical ON skills_dictionary(canonical_name);
CREATE INDEX IF NOT EXISTS idx_skills_dict_category ON skills_dictionary(category);

COMMENT ON TABLE skills_dictionary IS 'Skills dictionary with canonical names and synonyms';
COMMENT ON COLUMN skills_dictionary.name IS 'User-entered skill name (any language, synonym)';
COMMENT ON COLUMN skills_dictionary.canonical_name IS 'Canonical skill name (English)';

-- ============================================================================
-- TABLE: candidate_skills
-- Candidate skills (many-to-many through skills_dictionary)
-- ============================================================================
CREATE TABLE IF NOT EXISTS candidate_skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  skill_name VARCHAR(255) NOT NULL,
  canonical_skill VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(candidate_id, canonical_skill)
);

CREATE INDEX IF NOT EXISTS idx_candidate_skills_candidate ON candidate_skills(candidate_id);
CREATE INDEX IF NOT EXISTS idx_candidate_skills_canonical ON candidate_skills(canonical_skill);

COMMENT ON TABLE candidate_skills IS 'Skills associated with candidates';
COMMENT ON COLUMN candidate_skills.skill_name IS 'Skill as entered by user';
COMMENT ON COLUMN candidate_skills.canonical_skill IS 'Canonical skill from dictionary';

-- ============================================================================
-- TRIGGER: updated_at auto-update for candidates
-- ============================================================================
CREATE TRIGGER update_candidates_updated_at
  BEFORE UPDATE ON candidates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Search skills in dictionary
-- ============================================================================
CREATE OR REPLACE FUNCTION search_skill(skill_input VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
  result VARCHAR;
BEGIN
  -- Try exact match first
  SELECT canonical_name INTO result
  FROM skills_dictionary
  WHERE LOWER(name) = LOWER(skill_input)
  LIMIT 1;

  -- If not found, return input as canonical
  IF result IS NULL THEN
    result := skill_input;
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION search_skill IS 'Search for canonical skill name in dictionary';
-- ============================================================================
-- VACANCIES SCHEMA MIGRATION
-- Creates tables: vacancies, applications, invitation_tokens, org_invitation_tokens
-- ============================================================================

-- ============================================================================
-- TABLE: vacancies
-- Job vacancies from HR specialists
-- ============================================================================
CREATE TABLE IF NOT EXISTS vacancies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  created_by UUID REFERENCES hr_specialists(id) ON DELETE SET NULL,

  -- Basic information
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  requirements TEXT,
  location VARCHAR(255),
  employment_type VARCHAR(50) CHECK (employment_type IN ('full-time', 'part-time', 'contract', 'internship')),
  salary_min INTEGER,
  salary_max INTEGER,
  salary_currency VARCHAR(10) DEFAULT 'KZT',

  -- Ideal profile (generated by AI + manually edited)
  ideal_profile JSONB,

  -- Required skills (selected by HR manually)
  required_skills TEXT[],

  -- Status
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archived')),

  -- Statistics
  candidates_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vacancies_org ON vacancies(organization_id);
CREATE INDEX IF NOT EXISTS idx_vacancies_created_by ON vacancies(created_by);
CREATE INDEX IF NOT EXISTS idx_vacancies_status ON vacancies(status);
CREATE INDEX IF NOT EXISTS idx_vacancies_employment_type ON vacancies(employment_type);

COMMENT ON TABLE vacancies IS 'Job vacancies posted by organizations';
COMMENT ON COLUMN vacancies.ideal_profile IS 'AI-generated and manually edited ideal candidate profile (JSON)';
COMMENT ON COLUMN vacancies.required_skills IS 'Array of canonical skill names from skills_dictionary';

-- ============================================================================
-- TABLE: invitation_tokens
-- Invitation tokens for candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS invitation_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  token VARCHAR(255) NOT NULL UNIQUE,
  hr_specialist_id UUID REFERENCES hr_specialists(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  vacancy_ids UUID[],
  is_used BOOLEAN DEFAULT false,
  used_by UUID REFERENCES candidates(id) ON DELETE SET NULL,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_invitation_tokens_token ON invitation_tokens(token);
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_hr ON invitation_tokens(hr_specialist_id);
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_org ON invitation_tokens(organization_id);
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_used ON invitation_tokens(is_used) WHERE is_used = false;
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_expires ON invitation_tokens(expires_at) WHERE is_used = false;

COMMENT ON TABLE invitation_tokens IS 'Invitation tokens for candidates to register';
COMMENT ON COLUMN invitation_tokens.vacancy_ids IS 'Array of vacancy IDs this invitation is for';

-- ============================================================================
-- TABLE: org_invitation_tokens
-- Invitation tokens for HR to join organization
-- ============================================================================
CREATE TABLE IF NOT EXISTS org_invitation_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  token VARCHAR(255) NOT NULL UNIQUE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  invited_by UUID REFERENCES hr_specialists(id) ON DELETE SET NULL,
  email VARCHAR(255),
  is_used BOOLEAN DEFAULT false,
  used_by UUID REFERENCES hr_specialists(id) ON DELETE SET NULL,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_token ON org_invitation_tokens(token);
CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_org ON org_invitation_tokens(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_email ON org_invitation_tokens(email);

COMMENT ON TABLE org_invitation_tokens IS 'Invitation tokens for HR specialists to join organization';

-- ============================================================================
-- TABLE: applications
-- Link between candidates and vacancies (applications)
-- ============================================================================
CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  vacancy_id UUID REFERENCES vacancies(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

  -- Source of candidate
  source VARCHAR(50) NOT NULL CHECK (source IN ('invitation', 'talent_market')),
  invited_by UUID REFERENCES hr_specialists(id) ON DELETE SET NULL,
  acquired_by UUID REFERENCES hr_specialists(id) ON DELETE SET NULL,

  -- Status in vacancy pipeline
  status VARCHAR(50) DEFAULT 'invited' CHECK (status IN (
    'invited', 'registered', 'testing', 'tested', 'analyzed',
    'saved', 'interview', 'offer', 'hired', 'rejected'
  )),

  -- Compatibility score (calculated)
  compatibility_score INTEGER CHECK (compatibility_score >= 0 AND compatibility_score <= 100),

  -- Notes from HR
  notes TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(candidate_id, vacancy_id)
);

CREATE INDEX IF NOT EXISTS idx_applications_candidate ON applications(candidate_id);
CREATE INDEX IF NOT EXISTS idx_applications_vacancy ON applications(vacancy_id);
CREATE INDEX IF NOT EXISTS idx_applications_org ON applications(organization_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_source ON applications(source);
CREATE INDEX IF NOT EXISTS idx_applications_score ON applications(compatibility_score);

COMMENT ON TABLE applications IS 'Applications (link between candidates and vacancies)';
COMMENT ON COLUMN applications.source IS 'How candidate was added: invitation or talent_market';
COMMENT ON COLUMN applications.compatibility_score IS 'AI-calculated compatibility score (0-100)';

-- ============================================================================
-- TRIGGERS: updated_at auto-update
-- ============================================================================
CREATE TRIGGER update_vacancies_updated_at
  BEFORE UPDATE ON vacancies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Generate random invitation token
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS VARCHAR AS $$
DECLARE
  characters TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  result VARCHAR := '';
  i INTEGER;
BEGIN
  FOR i IN 1..32 LOOP
    result := result || substr(characters, floor(random() * length(characters) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_invitation_token IS 'Generate random 32-character invitation token';
-- ============================================================================
-- TESTS AND AI SCHEMA MIGRATION
-- Creates tables: test_results, ai_analysis_results, messages, ai_models_config, operation_costs
-- ============================================================================

-- ============================================================================
-- TABLE: test_results
-- Results from psychometric tests
-- ============================================================================
CREATE TABLE IF NOT EXISTS test_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  test_type VARCHAR(50) NOT NULL CHECK (test_type IN (
    'professional_skills', 'logical_thinking', 'personality',
    'emotional_intelligence', 'motivation', 'leadership'
  )),

  -- Test data
  questions_answers JSONB NOT NULL,
  score INTEGER CHECK (score >= 0 AND score <= 100),

  -- Analysis
  analysis JSONB,

  -- Freshness tracking
  is_outdated BOOLEAN DEFAULT false,
  valid_until TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(candidate_id, test_type)
);

CREATE INDEX IF NOT EXISTS idx_test_results_candidate ON test_results(candidate_id);
CREATE INDEX IF NOT EXISTS idx_test_results_test_type ON test_results(test_type);
CREATE INDEX IF NOT EXISTS idx_test_results_outdated ON test_results(is_outdated) WHERE is_outdated = false;
CREATE INDEX IF NOT EXISTS idx_test_results_score ON test_results(score);

COMMENT ON TABLE test_results IS 'Psychometric test results for candidates';
COMMENT ON COLUMN test_results.questions_answers IS 'JSON with questions and answers';
COMMENT ON COLUMN test_results.analysis IS 'AI-generated analysis of test results';
COMMENT ON COLUMN test_results.valid_until IS 'Test validity expiration date (6 months from creation)';

-- ============================================================================
-- TABLE: ai_analysis_results
-- AI-generated analysis results
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_analysis_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  vacancy_id UUID REFERENCES vacancies(id) ON DELETE SET NULL,
  application_id UUID REFERENCES applications(id) ON DELETE CASCADE,

  -- Analysis type
  analysis_type VARCHAR(50) NOT NULL CHECK (analysis_type IN (
    'full_analysis', 'vacancy_match', 'interview_guide', 'comparison'
  )),

  -- Results
  result JSONB NOT NULL,

  -- Token usage
  tokens_used INTEGER DEFAULT 0,
  model_used VARCHAR(50),

  -- PDF export
  pdf_url TEXT,
  is_public BOOLEAN DEFAULT false,
  public_token VARCHAR(255) UNIQUE,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_analysis_candidate ON ai_analysis_results(candidate_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_vacancy ON ai_analysis_results(vacancy_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_application ON ai_analysis_results(application_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_type ON ai_analysis_results(analysis_type);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_public ON ai_analysis_results(public_token) WHERE is_public = true;

COMMENT ON TABLE ai_analysis_results IS 'AI-generated analysis results (full analysis, match reports, etc)';
COMMENT ON COLUMN ai_analysis_results.public_token IS 'Token for public access to PDF report';

-- ============================================================================
-- TABLE: messages
-- Chat messages between HR and candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL,
  sender_type VARCHAR(20) NOT NULL CHECK (sender_type IN ('hr', 'candidate')),
  recipient_id UUID NOT NULL,
  recipient_type VARCHAR(20) NOT NULL CHECK (recipient_type IN ('hr', 'candidate')),

  -- Message content
  content TEXT NOT NULL,

  -- Read status
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id, sender_type);
CREATE INDEX IF NOT EXISTS idx_messages_recipient ON messages(recipient_id, recipient_type);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);

COMMENT ON TABLE messages IS 'Chat messages between HR specialists and candidates';

-- ============================================================================
-- TABLE: ai_models_config
-- Configuration for AI models
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_models_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  model_name VARCHAR(100) NOT NULL UNIQUE,
  provider VARCHAR(50) NOT NULL,

  -- Pricing (per 1M tokens)
  input_price_per_million DECIMAL(10, 2) NOT NULL,
  output_price_per_million DECIMAL(10, 2) NOT NULL,

  -- Limits
  max_input_tokens INTEGER,
  max_output_tokens INTEGER,

  -- Status
  is_active BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_models_active ON ai_models_config(is_active) WHERE is_active = true;

COMMENT ON TABLE ai_models_config IS 'AI models configuration and pricing';

-- ============================================================================
-- TABLE: operation_costs
-- Fixed costs for operations
-- ============================================================================
CREATE TABLE IF NOT EXISTS operation_costs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  operation_name VARCHAR(100) NOT NULL UNIQUE,
  cost_in_tokens INTEGER NOT NULL CHECK (cost_in_tokens >= 0),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_operation_costs_active ON operation_costs(is_active) WHERE is_active = true;

COMMENT ON TABLE operation_costs IS 'Fixed token costs for various operations';

-- ============================================================================
-- INITIAL DATA: ai_models_config
-- ============================================================================
INSERT INTO ai_models_config (model_name, provider, input_price_per_million, output_price_per_million, max_input_tokens, max_output_tokens) VALUES
  ('claude-3-5-sonnet-20241022', 'anthropic', 3.00, 15.00, 200000, 8192),
  ('claude-3-5-haiku-20241022', 'anthropic', 0.80, 4.00, 200000, 8192),
  ('gpt-4o', 'openai', 2.50, 10.00, 128000, 16384),
  ('gpt-4o-mini', 'openai', 0.15, 0.60, 128000, 16384),
  ('gemini-1.5-pro', 'google', 1.25, 5.00, 2000000, 8192),
  ('gemini-1.5-flash', 'google', 0.075, 0.30, 1000000, 8192)
ON CONFLICT (model_name) DO NOTHING;

-- ============================================================================
-- INITIAL DATA: operation_costs
-- ============================================================================
INSERT INTO operation_costs (operation_name, cost_in_tokens, description) VALUES
  ('create_invitation_link', 10, 'Cost to create invitation link'),
  ('acquire_from_talent_market', 500, 'Cost to acquire candidate from Talent Market'),
  ('resume_quick_analysis', 50, 'Quick resume analysis (basic info extraction)'),
  ('generate_ideal_profile', 200, 'Generate ideal candidate profile for vacancy')
ON CONFLICT (operation_name) DO NOTHING;

-- ============================================================================
-- TRIGGERS: updated_at auto-update
-- ============================================================================
CREATE TRIGGER update_ai_models_config_updated_at
  BEFORE UPDATE ON ai_models_config
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_operation_costs_updated_at
  BEFORE UPDATE ON operation_costs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
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
-- ============================================================================
-- RLS POLICIES MIGRATION
-- Creates Row Level Security policies for all tables
-- ============================================================================

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE hr_specialists ENABLE ROW LEVEL SECURITY;
ALTER TABLE professional_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidate_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills_dictionary ENABLE ROW LEVEL SECURITY;
ALTER TABLE vacancies ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitation_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE org_invitation_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_analysis_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_models_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE operation_costs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTIONS FOR RLS
-- ============================================================================

-- Get current user's organization ID (for HR)
CREATE OR REPLACE FUNCTION auth.user_organization_id()
RETURNS UUID AS $$
  SELECT organization_id FROM hr_specialists WHERE user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if current user is HR specialist
CREATE OR REPLACE FUNCTION auth.is_hr()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM hr_specialists WHERE user_id = auth.uid())
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if current user is candidate
CREATE OR REPLACE FUNCTION auth.is_candidate()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM candidates WHERE user_id = auth.uid())
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if current user is organization owner
CREATE OR REPLACE FUNCTION auth.is_org_owner()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM hr_specialists
    WHERE user_id = auth.uid() AND role = 'owner'
  )
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================================
-- RLS POLICIES: organizations
-- ============================================================================
CREATE POLICY "HR can view their own organization"
  ON organizations FOR SELECT
  USING (id = auth.user_organization_id());

CREATE POLICY "Organization owners can update their organization"
  ON organizations FOR UPDATE
  USING (
    id = auth.user_organization_id()
    AND auth.is_org_owner()
  );

-- ============================================================================
-- RLS POLICIES: hr_specialists
-- ============================================================================
CREATE POLICY "HR can view colleagues in same organization"
  ON hr_specialists FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Organization owners can invite HR specialists"
  ON hr_specialists FOR INSERT
  WITH CHECK (
    organization_id = auth.user_organization_id()
    AND auth.is_org_owner()
  );

-- ============================================================================
-- RLS POLICIES: professional_categories
-- ============================================================================
CREATE POLICY "Anyone can view professional categories"
  ON professional_categories FOR SELECT
  USING (true);

-- ============================================================================
-- RLS POLICIES: candidates
-- ============================================================================
CREATE POLICY "Candidates can view own profile"
  ON candidates FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Candidates can update own profile"
  ON candidates FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "HR can view public candidates"
  ON candidates FOR SELECT
  USING (
    auth.is_hr()
    AND (
      is_public = true
      OR id IN (
        SELECT candidate_id FROM applications
        WHERE organization_id = auth.user_organization_id()
      )
    )
  );

-- ============================================================================
-- RLS POLICIES: candidate_skills
-- ============================================================================
CREATE POLICY "Candidates can manage own skills"
  ON candidate_skills FOR ALL
  USING (
    candidate_id IN (SELECT id FROM candidates WHERE user_id = auth.uid())
  );

CREATE POLICY "HR can view candidate skills"
  ON candidate_skills FOR SELECT
  USING (
    auth.is_hr()
    AND candidate_id IN (
      SELECT id FROM candidates WHERE is_public = true
      UNION
      SELECT candidate_id FROM applications
      WHERE organization_id = auth.user_organization_id()
    )
  );

-- ============================================================================
-- RLS POLICIES: skills_dictionary
-- ============================================================================
CREATE POLICY "Anyone can view skills dictionary"
  ON skills_dictionary FOR SELECT
  USING (true);

-- ============================================================================
-- RLS POLICIES: vacancies
-- ============================================================================
CREATE POLICY "HR can view vacancies in their organization"
  ON vacancies FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "HR can create vacancies"
  ON vacancies FOR INSERT
  WITH CHECK (
    auth.is_hr()
    AND organization_id = auth.user_organization_id()
  );

CREATE POLICY "HR can update vacancies in their organization"
  ON vacancies FOR UPDATE
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "HR can delete vacancies in their organization"
  ON vacancies FOR DELETE
  USING (organization_id = auth.user_organization_id());

-- ============================================================================
-- RLS POLICIES: applications
-- ============================================================================
CREATE POLICY "HR can view applications in their organization"
  ON applications FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "HR can create applications"
  ON applications FOR INSERT
  WITH CHECK (
    auth.is_hr()
    AND organization_id = auth.user_organization_id()
  );

CREATE POLICY "HR can update applications"
  ON applications FOR UPDATE
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "Candidates can view own applications"
  ON applications FOR SELECT
  USING (
    candidate_id IN (SELECT id FROM candidates WHERE user_id = auth.uid())
  );

-- ============================================================================
-- RLS POLICIES: invitation_tokens
-- ============================================================================
CREATE POLICY "HR can view invitation tokens in their organization"
  ON invitation_tokens FOR SELECT
  USING (organization_id = auth.user_organization_id());

CREATE POLICY "HR can create invitation tokens"
  ON invitation_tokens FOR INSERT
  WITH CHECK (
    auth.is_hr()
    AND organization_id = auth.user_organization_id()
  );

CREATE POLICY "Anyone can view valid invitation token"
  ON invitation_tokens FOR SELECT
  USING (is_used = false AND expires_at > NOW());

-- ============================================================================
-- RLS POLICIES: org_invitation_tokens
-- ============================================================================
CREATE POLICY "Organization owners can manage org invitations"
  ON org_invitation_tokens FOR ALL
  USING (
    organization_id = auth.user_organization_id()
    AND auth.is_org_owner()
  );

CREATE POLICY "Anyone can view valid org invitation token"
  ON org_invitation_tokens FOR SELECT
  USING (is_used = false AND expires_at > NOW());

-- ============================================================================
-- RLS POLICIES: test_results
-- ============================================================================
CREATE POLICY "Candidates can view own test results"
  ON test_results FOR SELECT
  USING (
    candidate_id IN (SELECT id FROM candidates WHERE user_id = auth.uid())
  );

CREATE POLICY "Candidates can create own test results"
  ON test_results FOR INSERT
  WITH CHECK (
    candidate_id IN (SELECT id FROM candidates WHERE user_id = auth.uid())
  );

CREATE POLICY "HR can view test results of their candidates"
  ON test_results FOR SELECT
  USING (
    auth.is_hr()
    AND candidate_id IN (
      SELECT candidate_id FROM applications
      WHERE organization_id = auth.user_organization_id()
    )
  );

-- ============================================================================
-- RLS POLICIES: ai_analysis_results
-- ============================================================================
CREATE POLICY "HR can view analysis in their organization"
  ON ai_analysis_results FOR SELECT
  USING (
    auth.is_hr()
    AND (
      vacancy_id IN (
        SELECT id FROM vacancies WHERE organization_id = auth.user_organization_id()
      )
      OR application_id IN (
        SELECT id FROM applications WHERE organization_id = auth.user_organization_id()
      )
    )
  );

CREATE POLICY "HR can create analysis"
  ON ai_analysis_results FOR INSERT
  WITH CHECK (auth.is_hr());

CREATE POLICY "Anyone can view public analysis"
  ON ai_analysis_results FOR SELECT
  USING (is_public = true);

-- ============================================================================
-- RLS POLICIES: messages
-- ============================================================================
CREATE POLICY "Users can view their own messages"
  ON messages FOR SELECT
  USING (
    (sender_id = auth.uid())
    OR (recipient_id = auth.uid())
  );

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update their received messages (mark as read)"
  ON messages FOR UPDATE
  USING (recipient_id = auth.uid());

-- ============================================================================
-- RLS POLICIES: ai_models_config
-- ============================================================================
CREATE POLICY "Anyone can view active AI models"
  ON ai_models_config FOR SELECT
  USING (is_active = true);

-- ============================================================================
-- RLS POLICIES: operation_costs
-- ============================================================================
CREATE POLICY "Anyone can view active operation costs"
  ON operation_costs FOR SELECT
  USING (is_active = true);

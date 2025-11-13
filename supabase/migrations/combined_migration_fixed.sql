-- ============================================================================
-- COMBINED MIGRATION FOR HR PLATFORM
-- Fixed version without auth.users triggers (creates profiles via client code)
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
-- Professional categories (e.g., IT, Marketing, Sales, etc.)
-- ============================================================================
CREATE TABLE IF NOT EXISTS professional_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ru VARCHAR(255) NOT NULL,
  name_kk VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_name_ru ON professional_categories(name_ru);
CREATE INDEX IF NOT EXISTS idx_categories_name_en ON professional_categories(name_en);

COMMENT ON TABLE professional_categories IS 'Professional categories for jobs and candidates';

-- Seed professional categories
INSERT INTO professional_categories (name_ru, name_kk, name_en) VALUES
  ('Информационные технологии', 'Ақпараттық технологиялар', 'Information Technology'),
  ('Маркетинг и реклама', 'Маркетинг және жарнама', 'Marketing and Advertising'),
  ('Продажи', 'Сату', 'Sales'),
  ('Бухгалтерия и финансы', 'Бухгалтерия және қаржы', 'Accounting and Finance'),
  ('Управление персоналом', 'Персоналды басқару', 'Human Resources'),
  ('Логистика', 'Логистика', 'Logistics'),
  ('Производство', 'Өндіріс', 'Manufacturing'),
  ('Строительство', 'Құрылыс', 'Construction'),
  ('Образование', 'Білім беру', 'Education'),
  ('Медицина', 'Медицина', 'Healthcare'),
  ('Юриспруденция', 'Заң', 'Legal'),
  ('Дизайн', 'Дизайн', 'Design'),
  ('Другое', 'Басқа', 'Other')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- TABLE: candidates
-- Candidate profiles
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
  tests_completed INTEGER DEFAULT 0 CHECK (tests_completed >= 0),
  profile_completeness INTEGER DEFAULT 20 CHECK (profile_completeness >= 0 AND profile_completeness <= 100),
  profile_last_updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_candidates_user ON candidates(user_id);
CREATE INDEX IF NOT EXISTS idx_candidates_email ON candidates(email);
CREATE INDEX IF NOT EXISTS idx_candidates_category ON candidates(category_id);
CREATE INDEX IF NOT EXISTS idx_candidates_public ON candidates(is_public);
CREATE INDEX IF NOT EXISTS idx_candidates_completeness ON candidates(profile_completeness);

COMMENT ON TABLE candidates IS 'Candidate profiles for job seekers';
COMMENT ON COLUMN candidates.profile_completeness IS 'Profile completion percentage (0-100%)';
COMMENT ON COLUMN candidates.is_public IS 'Whether profile is visible in talent market';

-- ============================================================================
-- TABLE: candidate_skills
-- Skills associated with candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS candidate_skills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  skill_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_candidate_skills_candidate ON candidate_skills(candidate_id);
CREATE INDEX IF NOT EXISTS idx_candidate_skills_name ON candidate_skills(skill_name);

COMMENT ON TABLE candidate_skills IS 'Skills that candidates possess';

-- ============================================================================
-- TABLE: skills_dictionary
-- Dictionary of available skills
-- ============================================================================
CREATE TABLE IF NOT EXISTS skills_dictionary (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_ru VARCHAR(255) NOT NULL UNIQUE,
  name_kk VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  category_id UUID REFERENCES professional_categories(id),
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_skills_dict_name_ru ON skills_dictionary(name_ru);
CREATE INDEX IF NOT EXISTS idx_skills_dict_category ON skills_dictionary(category_id);
CREATE INDEX IF NOT EXISTS idx_skills_dict_usage ON skills_dictionary(usage_count DESC);

COMMENT ON TABLE skills_dictionary IS 'Dictionary of skills for autocomplete and standardization';

-- ============================================================================
-- FUNCTION: Search skills by partial match
-- ============================================================================
CREATE OR REPLACE FUNCTION search_skill(search_term TEXT, lang TEXT DEFAULT 'ru')
RETURNS TABLE(id UUID, name TEXT, category_id UUID, usage_count INTEGER) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sd.id,
    CASE
      WHEN lang = 'kk' THEN sd.name_kk
      WHEN lang = 'en' THEN sd.name_en
      ELSE sd.name_ru
    END as name,
    sd.category_id,
    sd.usage_count
  FROM skills_dictionary sd
  WHERE
    (lang = 'ru' AND sd.name_ru ILIKE '%' || search_term || '%') OR
    (lang = 'kk' AND sd.name_kk ILIKE '%' || search_term || '%') OR
    (lang = 'en' AND sd.name_en ILIKE '%' || search_term || '%')
  ORDER BY sd.usage_count DESC, name ASC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION search_skill IS 'Search skills by partial match with language support';

-- ============================================================================
-- TABLE: vacancies
-- Job vacancies posted by HR specialists
-- ============================================================================
CREATE TABLE IF NOT EXISTS vacancies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  hr_specialist_id UUID NOT NULL REFERENCES hr_specialists(id),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category_id UUID REFERENCES professional_categories(id),
  requirements TEXT,
  salary_min INTEGER,
  salary_max INTEGER,
  location VARCHAR(255),
  employment_type VARCHAR(50) CHECK (employment_type IN ('full_time', 'part_time', 'contract', 'internship')),
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'paused', 'closed')),
  views_count INTEGER DEFAULT 0,
  applications_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_vacancies_org ON vacancies(organization_id);
CREATE INDEX IF NOT EXISTS idx_vacancies_hr ON vacancies(hr_specialist_id);
CREATE INDEX IF NOT EXISTS idx_vacancies_category ON vacancies(category_id);
CREATE INDEX IF NOT EXISTS idx_vacancies_status ON vacancies(status);
CREATE INDEX IF NOT EXISTS idx_vacancies_published ON vacancies(published_at DESC);

COMMENT ON TABLE vacancies IS 'Job vacancies posted by organizations';
COMMENT ON COLUMN vacancies.status IS 'Vacancy status: draft, active, paused, or closed';

-- ============================================================================
-- TABLE: applications
-- Candidate applications to vacancies
-- ============================================================================
CREATE TABLE IF NOT EXISTS applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vacancy_id UUID NOT NULL REFERENCES vacancies(id) ON DELETE CASCADE,
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  cover_letter TEXT,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'interview', 'offer', 'rejected', 'accepted', 'withdrawn')),
  ai_match_score INTEGER CHECK (ai_match_score >= 0 AND ai_match_score <= 100),
  hr_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  UNIQUE(vacancy_id, candidate_id)
);

CREATE INDEX IF NOT EXISTS idx_applications_vacancy ON applications(vacancy_id);
CREATE INDEX IF NOT EXISTS idx_applications_candidate ON applications(candidate_id);
CREATE INDEX IF NOT EXISTS idx_applications_org ON applications(organization_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_score ON applications(ai_match_score DESC);

COMMENT ON TABLE applications IS 'Candidate applications to job vacancies';
COMMENT ON COLUMN applications.ai_match_score IS 'AI-calculated match score between candidate and vacancy (0-100%)';

-- ============================================================================
-- TABLE: invitation_tokens
-- Tokens for candidate invitations
-- ============================================================================
CREATE TABLE IF NOT EXISTS invitation_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vacancy_id UUID NOT NULL REFERENCES vacancies(id) ON DELETE CASCADE,
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  token VARCHAR(255) NOT NULL UNIQUE,
  message TEXT,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_invitation_tokens_token ON invitation_tokens(token);
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_candidate ON invitation_tokens(candidate_id);
CREATE INDEX IF NOT EXISTS idx_invitation_tokens_status ON invitation_tokens(status);

COMMENT ON TABLE invitation_tokens IS 'Invitation tokens for candidates from HR';

-- ============================================================================
-- TABLE: org_invitation_tokens
-- Organization invitation tokens for adding HR team members
-- ============================================================================
CREATE TABLE IF NOT EXISTS org_invitation_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES hr_specialists(id),
  email VARCHAR(255) NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('member', 'owner')),
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'expired')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_token ON org_invitation_tokens(token);
CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_email ON org_invitation_tokens(email);
CREATE INDEX IF NOT EXISTS idx_org_invitation_tokens_status ON org_invitation_tokens(status);

COMMENT ON TABLE org_invitation_tokens IS 'Invitation tokens for adding HR team members to organizations';

-- ============================================================================
-- FUNCTION: Generate random invitation token
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS TEXT AS $$
BEGIN
  RETURN encode(gen_random_bytes(32), 'hex');
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_invitation_token IS 'Generate secure random token for invitations';

-- ============================================================================
-- TABLE: test_results
-- Test results for candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS test_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  test_type VARCHAR(100) NOT NULL CHECK (test_type IN ('personality', 'iq', 'eq', 'technical', 'language', 'custom')),
  test_name VARCHAR(255) NOT NULL,
  score INTEGER CHECK (score >= 0 AND score <= 100),
  raw_results JSONB,
  interpretation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_test_results_candidate ON test_results(candidate_id);
CREATE INDEX IF NOT EXISTS idx_test_results_type ON test_results(test_type);
CREATE INDEX IF NOT EXISTS idx_test_results_completed ON test_results(completed_at DESC);

COMMENT ON TABLE test_results IS 'Test results for candidate assessments';
COMMENT ON COLUMN test_results.raw_results IS 'Full test results in JSON format';

-- ============================================================================
-- TABLE: ai_analysis_results
-- AI analysis results for candidates and applications
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_analysis_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidate_id UUID REFERENCES candidates(id) ON DELETE CASCADE,
  application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
  vacancy_id UUID REFERENCES vacancies(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  analysis_type VARCHAR(100) NOT NULL CHECK (analysis_type IN ('profile_analysis', 'vacancy_match', 'resume_screening', 'interview_preparation')),
  ai_model VARCHAR(100) NOT NULL,
  input_data JSONB,
  analysis_result JSONB NOT NULL,
  tokens_used INTEGER DEFAULT 0,
  cost INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_analysis_candidate ON ai_analysis_results(candidate_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_application ON ai_analysis_results(application_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_org ON ai_analysis_results(organization_id);
CREATE INDEX IF NOT EXISTS idx_ai_analysis_type ON ai_analysis_results(analysis_type);

COMMENT ON TABLE ai_analysis_results IS 'AI analysis results for various HR operations';
COMMENT ON COLUMN ai_analysis_results.cost IS 'Cost in platform tokens for this analysis';

-- ============================================================================
-- TABLE: messages
-- Messages between HR and candidates
-- ============================================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL,
  sender_type VARCHAR(50) NOT NULL CHECK (sender_type IN ('hr_specialist', 'candidate')),
  recipient_id UUID NOT NULL,
  recipient_type VARCHAR(50) NOT NULL CHECK (recipient_type IN ('hr_specialist', 'candidate')),
  application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id, sender_type);
CREATE INDEX IF NOT EXISTS idx_messages_recipient ON messages(recipient_id, recipient_type);
CREATE INDEX IF NOT EXISTS idx_messages_application ON messages(application_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(recipient_id, is_read) WHERE is_read = false;

COMMENT ON TABLE messages IS 'Messages between HR specialists and candidates';

-- ============================================================================
-- TABLE: ai_models_config
-- Configuration for AI models and their costs
-- ============================================================================
CREATE TABLE IF NOT EXISTS ai_models_config (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  model_name VARCHAR(100) NOT NULL UNIQUE,
  provider VARCHAR(100) NOT NULL,
  cost_per_1k_tokens INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  capabilities JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_models_active ON ai_models_config(is_active);

COMMENT ON TABLE ai_models_config IS 'Configuration and pricing for AI models';
COMMENT ON COLUMN ai_models_config.cost_per_1k_tokens IS 'Cost in platform tokens per 1000 AI tokens';

-- Seed AI models
INSERT INTO ai_models_config (model_name, provider, cost_per_1k_tokens, capabilities) VALUES
  ('gpt-4o', 'OpenAI', 5, '{"use_cases": ["complex_analysis", "interview_prep", "detailed_matching"]}'),
  ('gpt-4o-mini', 'OpenAI', 1, '{"use_cases": ["quick_screening", "basic_matching", "simple_analysis"]}'),
  ('claude-3-5-sonnet', 'Anthropic', 4, '{"use_cases": ["resume_analysis", "candidate_matching", "interview_questions"]}'),
  ('claude-3-haiku', 'Anthropic', 1, '{"use_cases": ["quick_checks", "basic_screening"]}'),
  ('gemini-1.5-pro', 'Google', 3, '{"use_cases": ["multilingual_analysis", "detailed_screening"]}'),
  ('gemini-1.5-flash', 'Google', 1, '{"use_cases": ["fast_screening", "basic_checks"]}')
ON CONFLICT (model_name) DO NOTHING;

-- ============================================================================
-- TABLE: operation_costs
-- Predefined costs for different operations
-- ============================================================================
CREATE TABLE IF NOT EXISTS operation_costs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  operation_type VARCHAR(100) NOT NULL UNIQUE,
  base_cost INTEGER NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_operation_costs_type ON operation_costs(operation_type);

COMMENT ON TABLE operation_costs IS 'Token costs for different platform operations';

-- Seed operation costs
INSERT INTO operation_costs (operation_type, base_cost, description) VALUES
  ('ai_candidate_match', 10, 'AI matching between candidate and vacancy'),
  ('ai_resume_analysis', 15, 'Detailed AI analysis of candidate resume'),
  ('ai_interview_prep', 20, 'AI-generated interview questions and preparation'),
  ('candidate_invitation', 5, 'Sending invitation to candidate')
ON CONFLICT (operation_type) DO NOTHING;

-- ============================================================================
-- HELPER FUNCTIONS FOR PROFILE CREATION
-- These will be called from client code after user registration
-- ============================================================================

-- ============================================================================
-- FUNCTION: Create HR specialist profile (called from client)
-- ============================================================================
CREATE OR REPLACE FUNCTION create_hr_specialist_profile(
  p_user_id UUID,
  p_email TEXT,
  p_full_name TEXT,
  p_organization_name TEXT
)
RETURNS UUID AS $$
DECLARE
  v_org_id UUID;
  v_hr_id UUID;
BEGIN
  -- Create organization
  INSERT INTO organizations (name, owner_id, token_balance)
  VALUES (p_organization_name, p_user_id, 1000)
  RETURNING id INTO v_org_id;

  -- Create HR specialist profile
  INSERT INTO hr_specialists (user_id, organization_id, full_name, email, role)
  VALUES (p_user_id, v_org_id, p_full_name, p_email, 'owner')
  RETURNING id INTO v_hr_id;

  RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_hr_specialist_profile IS 'Create HR specialist profile and organization after signup';

-- ============================================================================
-- FUNCTION: Create candidate profile (called from client)
-- ============================================================================
CREATE OR REPLACE FUNCTION create_candidate_profile(
  p_user_id UUID,
  p_email TEXT,
  p_full_name TEXT
)
RETURNS UUID AS $$
DECLARE
  v_candidate_id UUID;
BEGIN
  -- Create candidate profile
  INSERT INTO candidates (
    user_id,
    full_name,
    email,
    tests_completed,
    profile_completeness,
    is_public
  ) VALUES (
    p_user_id,
    p_full_name,
    p_email,
    0,
    20,
    true
  )
  RETURNING id INTO v_candidate_id;

  RETURN v_candidate_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_candidate_profile IS 'Create candidate profile after signup';

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
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
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
-- POLICIES: organizations
-- ============================================================================

-- HR specialists can view their own organization
CREATE POLICY "HR can view own organization"
  ON organizations FOR SELECT
  USING (
    id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- HR specialists can update their own organization (owner only)
CREATE POLICY "HR owner can update organization"
  ON organizations FOR UPDATE
  USING (
    id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- ============================================================================
-- POLICIES: hr_specialists
-- ============================================================================

-- HR specialists can view colleagues in same organization
CREATE POLICY "HR can view colleagues"
  ON hr_specialists FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- HR specialists can view their own profile
CREATE POLICY "HR can view own profile"
  ON hr_specialists FOR SELECT
  USING (user_id = auth.uid());

-- HR specialists can insert their own profile (during signup)
CREATE POLICY "HR can insert own profile"
  ON hr_specialists FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- POLICIES: professional_categories
-- ============================================================================

-- Everyone can view professional categories
CREATE POLICY "Anyone can view categories"
  ON professional_categories FOR SELECT
  USING (true);

-- ============================================================================
-- POLICIES: candidates
-- ============================================================================

-- Candidates can view and update their own profile
CREATE POLICY "Candidates can view own profile"
  ON candidates FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Candidates can update own profile"
  ON candidates FOR UPDATE
  USING (user_id = auth.uid());

-- Candidates can insert their own profile (during signup)
CREATE POLICY "Candidates can insert own profile"
  ON candidates FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- HR specialists can view public candidate profiles
CREATE POLICY "HR can view public candidates"
  ON candidates FOR SELECT
  USING (
    is_public = true AND
    EXISTS (
      SELECT 1 FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- HR specialists can view candidates who applied to their organization
CREATE POLICY "HR can view applicants"
  ON candidates FOR SELECT
  USING (
    id IN (
      SELECT candidate_id FROM applications
      WHERE organization_id IN (
        SELECT organization_id FROM hr_specialists
        WHERE user_id = auth.uid()
      )
    )
  );

-- ============================================================================
-- POLICIES: candidate_skills
-- ============================================================================

-- Candidates can manage their own skills
CREATE POLICY "Candidates can manage own skills"
  ON candidate_skills FOR ALL
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- HR can view skills of public candidates and applicants
CREATE POLICY "HR can view candidate skills"
  ON candidate_skills FOR SELECT
  USING (
    candidate_id IN (
      SELECT id FROM candidates
      WHERE is_public = true OR id IN (
        SELECT candidate_id FROM applications
        WHERE organization_id IN (
          SELECT organization_id FROM hr_specialists
          WHERE user_id = auth.uid()
        )
      )
    ) AND EXISTS (
      SELECT 1 FROM hr_specialists WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- POLICIES: skills_dictionary
-- ============================================================================

-- Everyone can view skills dictionary
CREATE POLICY "Anyone can view skills dictionary"
  ON skills_dictionary FOR SELECT
  USING (true);

-- ============================================================================
-- POLICIES: vacancies
-- ============================================================================

-- HR specialists can manage vacancies in their organization
CREATE POLICY "HR can manage org vacancies"
  ON vacancies FOR ALL
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- Candidates can view active vacancies
CREATE POLICY "Candidates can view active vacancies"
  ON vacancies FOR SELECT
  USING (
    status = 'active' AND
    EXISTS (
      SELECT 1 FROM candidates WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- POLICIES: applications
-- ============================================================================

-- Candidates can view and manage their own applications
CREATE POLICY "Candidates can manage own applications"
  ON applications FOR ALL
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- HR specialists can view applications to their organization
CREATE POLICY "HR can view org applications"
  ON applications FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- HR specialists can update applications to their organization
CREATE POLICY "HR can update org applications"
  ON applications FOR UPDATE
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- POLICIES: invitation_tokens
-- ============================================================================

-- HR specialists can create and view invitations for their organization
CREATE POLICY "HR can manage org invitations"
  ON invitation_tokens FOR ALL
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- Candidates can view invitations sent to them
CREATE POLICY "Candidates can view own invitations"
  ON invitation_tokens FOR SELECT
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- Candidates can update their invitation status
CREATE POLICY "Candidates can update invitation status"
  ON invitation_tokens FOR UPDATE
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- POLICIES: org_invitation_tokens
-- ============================================================================

-- HR owners can manage organization invitations
CREATE POLICY "HR owners can manage org invitations"
  ON org_invitation_tokens FOR ALL
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

-- ============================================================================
-- POLICIES: test_results
-- ============================================================================

-- Candidates can view and manage their own test results
CREATE POLICY "Candidates can manage own test results"
  ON test_results FOR ALL
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- HR can view test results of applicants
CREATE POLICY "HR can view applicant test results"
  ON test_results FOR SELECT
  USING (
    candidate_id IN (
      SELECT candidate_id FROM applications
      WHERE organization_id IN (
        SELECT organization_id FROM hr_specialists
        WHERE user_id = auth.uid()
      )
    )
  );

-- ============================================================================
-- POLICIES: ai_analysis_results
-- ============================================================================

-- HR specialists can view AI analyses for their organization
CREATE POLICY "HR can view org AI analyses"
  ON ai_analysis_results FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- HR specialists can create AI analyses for their organization
CREATE POLICY "HR can create AI analyses"
  ON ai_analysis_results FOR INSERT
  WITH CHECK (
    organization_id IN (
      SELECT organization_id FROM hr_specialists
      WHERE user_id = auth.uid()
    )
  );

-- Candidates can view AI analyses related to them
CREATE POLICY "Candidates can view own AI analyses"
  ON ai_analysis_results FOR SELECT
  USING (
    candidate_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- POLICIES: messages
-- ============================================================================

-- Users can view messages sent to them or sent by them
CREATE POLICY "Users can view own messages"
  ON messages FOR SELECT
  USING (
    (sender_type = 'hr_specialist' AND sender_id IN (
      SELECT id FROM hr_specialists WHERE user_id = auth.uid()
    )) OR
    (sender_type = 'candidate' AND sender_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    )) OR
    (recipient_type = 'hr_specialist' AND recipient_id IN (
      SELECT id FROM hr_specialists WHERE user_id = auth.uid()
    )) OR
    (recipient_type = 'candidate' AND recipient_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    ))
  );

-- Users can send messages as themselves
CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (
    (sender_type = 'hr_specialist' AND sender_id IN (
      SELECT id FROM hr_specialists WHERE user_id = auth.uid()
    )) OR
    (sender_type = 'candidate' AND sender_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    ))
  );

-- Users can mark their messages as read
CREATE POLICY "Users can update own messages"
  ON messages FOR UPDATE
  USING (
    (recipient_type = 'hr_specialist' AND recipient_id IN (
      SELECT id FROM hr_specialists WHERE user_id = auth.uid()
    )) OR
    (recipient_type = 'candidate' AND recipient_id IN (
      SELECT id FROM candidates WHERE user_id = auth.uid()
    ))
  );

-- ============================================================================
-- POLICIES: ai_models_config
-- ============================================================================

-- Everyone can view active AI models
CREATE POLICY "Anyone can view active AI models"
  ON ai_models_config FOR SELECT
  USING (is_active = true);

-- ============================================================================
-- POLICIES: operation_costs
-- ============================================================================

-- Everyone can view operation costs
CREATE POLICY "Anyone can view operation costs"
  ON operation_costs FOR SELECT
  USING (true);

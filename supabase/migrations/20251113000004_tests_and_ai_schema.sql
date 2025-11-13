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

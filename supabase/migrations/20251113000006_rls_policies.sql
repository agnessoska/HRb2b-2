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

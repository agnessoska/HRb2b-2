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

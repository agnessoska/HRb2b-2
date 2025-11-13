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

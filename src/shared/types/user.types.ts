// User types for the HR Platform
export type UserRole = 'hr_specialist' | 'candidate';

export interface User {
  id: string;
  email: string;
  role: UserRole;
  created_at: string;
}

export interface HRSpecialist {
  id: string;
  user_id: string;
  organization_id: string;
  full_name: string;
  email: string;
  role: 'owner' | 'member';
  created_at: string;
  updated_at: string;
}

export interface Candidate {
  id: string;
  user_id: string;
  full_name: string;
  email: string;
  phone: string | null;
  category_id: string | null;
  work_experience: string | null;
  education: string | null;
  about_me: string | null;
  tests_completed: number;
  profile_completeness: number;
  is_public: boolean;
  profile_last_updated_at: string;
  created_at: string;
  updated_at: string;
}

export interface Organization {
  id: string;
  name: string;
  logo_url: string | null;
  owner_id: string | null;
  token_balance: number;
  created_at: string;
  updated_at: string;
}

export interface AuthUser {
  user: User;
  profile: HRSpecialist | Candidate;
  organization?: Organization; // Only for HR specialists
}

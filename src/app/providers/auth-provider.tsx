import React, { createContext, useContext, useEffect, useState } from 'react';
import type { User as SupabaseUser } from '@supabase/supabase-js';
import { supabase } from '@/shared/api/supabase';
import type { AuthUser, UserRole, HRSpecialist, Candidate, Organization } from '@/shared/types/user.types';

interface AuthContextType {
  user: SupabaseUser | null;
  authUser: AuthUser | null;
  loading: boolean;
  role: UserRole | null;
  organization: Organization | null;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, role: UserRole, userData: any) => Promise<void>;
  signOut: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<SupabaseUser | null>(null);
  const [authUser, setAuthUser] = useState<AuthUser | null>(null);
  const [organization, setOrganization] = useState<Organization | null>(null);
  const [loading, setLoading] = useState(true);
  const [role, setRole] = useState<UserRole | null>(null);

  // Load user profile (HR or Candidate)
  const loadUserProfile = async (userId: string, userEmail: string) => {
    try {
      // Try to load HR specialist first
      const { data: hrData, error: hrError } = await supabase
        .from('hr_specialists')
        .select('*, organizations(*)')
        .eq('user_id', userId)
        .single();

      if (!hrError && hrData) {
        const hr: HRSpecialist = hrData;
        const org: Organization = hrData.organizations;

        setRole('hr_specialist');
        setOrganization(org);
        setAuthUser({
          user: { id: userId, email: userEmail, role: 'hr_specialist', created_at: hr.created_at },
          profile: hr,
          organization: org,
        });
        return;
      }

      // Try to load candidate
      const { data: candidateData, error: candidateError } = await supabase
        .from('candidates')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (!candidateError && candidateData) {
        const candidate: Candidate = candidateData;

        setRole('candidate');
        setAuthUser({
          user: { id: userId, email: userEmail, role: 'candidate', created_at: candidate.created_at },
          profile: candidate,
        });
        return;
      }

      throw new Error('User profile not found');
    } catch (error) {
      console.error('Error loading user profile:', error);
      throw error;
    }
  };

  // Refresh user data
  const refreshUser = async () => {
    const { data: { user: currentUser } } = await supabase.auth.getUser();
    if (currentUser) {
      await loadUserProfile(currentUser.id, currentUser.email!);
    }
  };

  // Initialize auth state
  useEffect(() => {
    let mounted = true;

    async function initAuth() {
      try {
        const { data: { session } } = await supabase.auth.getSession();

        if (session?.user && mounted) {
          setUser(session.user);
          await loadUserProfile(session.user.id, session.user.email!);
        }
      } catch (error) {
        console.error('Error initializing auth:', error);
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    }

    initAuth();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;

        if (event === 'SIGNED_IN' && session?.user) {
          setUser(session.user);
          await loadUserProfile(session.user.id, session.user.email!);
        } else if (event === 'SIGNED_OUT') {
          setUser(null);
          setAuthUser(null);
          setRole(null);
          setOrganization(null);
        }
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  // Sign in
  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    if (data.user) {
      await loadUserProfile(data.user.id, data.user.email!);
    }
  };

  // Sign up
  const signUp = async (
    email: string,
    password: string,
    userRole: UserRole,
    userData: any
  ) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          role: userRole,
          ...userData,
        },
      },
    });

    if (error) throw error;
    if (!data.user) throw new Error('User creation failed');

    // Create profile based on role
    try {
      if (userRole === 'hr_specialist') {
        const { error: profileError } = await supabase.rpc('create_hr_specialist_profile', {
          p_user_id: data.user.id,
          p_email: email,
          p_full_name: userData.full_name,
          p_organization_name: userData.organization_name,
        });

        if (profileError) throw profileError;
      } else if (userRole === 'candidate') {
        const { error: profileError } = await supabase.rpc('create_candidate_profile', {
          p_user_id: data.user.id,
          p_email: email,
          p_full_name: userData.full_name,
        });

        if (profileError) throw profileError;
      }

      // Load the newly created profile
      await loadUserProfile(data.user.id, email);
    } catch (profileError: any) {
      // If profile creation fails, delete the auth user to maintain consistency
      console.error('Profile creation failed:', profileError);
      // Note: Can't easily delete the user here, so we'll throw the error
      throw new Error(`Profile creation failed: ${profileError.message}`);
    }
  };

  // Sign out
  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;

    setUser(null);
    setAuthUser(null);
    setRole(null);
    setOrganization(null);
  };

  const value: AuthContextType = {
    user,
    authUser,
    loading,
    role,
    organization,
    signIn,
    signUp,
    signOut,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

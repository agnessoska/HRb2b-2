import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/app/providers/auth-provider';
import type { UserRole } from '@/shared/types/user.types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  requireOwner?: boolean;
}

export function ProtectedRoute({ children, allowedRoles, requireOwner }: ProtectedRouteProps) {
  const { user, loading, role, authUser } = useAuth();
  const location = useLocation();

  // Show loading state
  if (loading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  // Not authenticated - redirect to login
  if (!user) {
    return <Navigate to="/auth/login" state={{ from: location }} replace />;
  }

  // Check role restrictions
  if (allowedRoles && role && !allowedRoles.includes(role)) {
    // Redirect to appropriate dashboard based on role
    const redirectPath = role === 'hr_specialist' ? '/hr/dashboard' : '/candidate/dashboard';
    return <Navigate to={redirectPath} replace />;
  }

  // Check owner restriction (only for HR specialists)
  if (requireOwner && role === 'hr_specialist') {
    const hrProfile = authUser?.profile as any;
    if (hrProfile?.role !== 'owner') {
      return <Navigate to="/hr/dashboard" replace />;
    }
  }

  return <>{children}</>;
}

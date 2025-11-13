import { createBrowserRouter, Navigate } from 'react-router-dom';
import { ProtectedRoute } from './protected-route';

// Layouts (will be created next)
import { AuthLayout } from '@/widgets/layouts/auth-layout';
import { DashboardLayout } from '@/widgets/layouts/dashboard-layout';

// Auth pages (will be created next)
import { LoginPage } from '@/pages/auth/login-page';

// HR pages (placeholders for now)
import { HRDashboardPage } from '@/pages/hr-dashboard';

// Candidate pages (placeholders for now)
import { CandidateDashboardPage } from '@/pages/candidate-dashboard';

export const router = createBrowserRouter([
  // Root redirect
  {
    path: '/',
    element: <Navigate to="/auth/login" replace />,
  },

  // Auth routes (public)
  {
    path: '/auth',
    element: <AuthLayout />,
    children: [
      {
        path: 'login',
        element: <LoginPage />,
      },
      {
        path: 'register/invite/:token',
        element: <div>Candidate Registration by Invite</div>, // TODO
      },
      {
        path: 'register/org-invite/:token',
        element: <div>HR Registration by Org Invite</div>, // TODO
      },
      {
        path: 'forgot-password',
        element: <div>Forgot Password</div>, // TODO
      },
    ],
  },

  // HR routes (protected)
  {
    path: '/hr',
    element: (
      <ProtectedRoute allowedRoles={['hr_specialist']}>
        <DashboardLayout />
      </ProtectedRoute>
    ),
    children: [
      {
        path: 'dashboard',
        element: <HRDashboardPage />,
      },
      {
        path: 'vacancies',
        element: <div>Vacancies Page</div>, // TODO
      },
      {
        path: 'vacancy/:id',
        element: <div>Vacancy Detail Page</div>, // TODO
      },
      {
        path: 'candidates',
        element: <div>Candidates Page</div>, // TODO
      },
      {
        path: 'candidate/:id',
        element: <div>Candidate Detail Page</div>, // TODO
      },
      {
        path: 'talent-market',
        element: <div>Talent Market Page</div>, // TODO
      },
      {
        path: 'chat',
        element: <div>Chat Page</div>, // TODO
      },
      {
        path: 'organization',
        element: (
          <ProtectedRoute requireOwner>
            <div>Organization Settings Page</div>
          </ProtectedRoute>
        ), // TODO
      },
      {
        path: 'profile',
        element: <div>HR Profile Page</div>, // TODO
      },
    ],
  },

  // Candidate routes (protected)
  {
    path: '/candidate',
    element: (
      <ProtectedRoute allowedRoles={['candidate']}>
        <DashboardLayout />
      </ProtectedRoute>
    ),
    children: [
      {
        path: 'dashboard',
        element: <CandidateDashboardPage />,
      },
      {
        path: 'tests',
        element: <div>Tests List Page</div>, // TODO
      },
      {
        path: 'test/:testType',
        element: <div>Test Taking Page</div>, // TODO
      },
      {
        path: 'results',
        element: <div>Test Results Page</div>, // TODO
      },
      {
        path: 'profile',
        element: <div>Candidate Profile Page</div>, // TODO
      },
      {
        path: 'chat',
        element: <div>Candidate Chat Page</div>, // TODO
      },
    ],
  },

  // Public report route
  {
    path: '/report/:reportId',
    element: <div>Public Report Page</div>, // TODO
  },

  // 404 page
  {
    path: '*',
    element: <div>404 - Page Not Found</div>, // TODO
  },
]);

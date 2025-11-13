import { useTranslation } from 'react-i18next';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card';
import { ClipboardList, Award, User, MessageSquare } from 'lucide-react';
import { useAuth } from '@/app/providers/auth-provider';
import { Button } from '@/shared/ui/button';
import { useNavigate } from 'react-router-dom';

export function CandidateDashboardPage() {
  const { t } = useTranslation('common');
  const { authUser } = useAuth();
  const navigate = useNavigate();

  const candidate = authUser?.profile as any; // Type assertion for now

  const profileCompleteness = candidate?.profile_completeness || 0;
  const testsCompleted = candidate?.tests_completed || 0;

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <Card className="bg-gradient-to-r from-blue-500 to-blue-600 text-white border-0">
        <CardContent className="p-6">
          <h2 className="text-2xl font-bold">
            {t('dashboard.welcomeCandidate', {
              name: candidate?.full_name || 'there',
              defaultValue: 'Welcome, {{name}}!',
            })}
          </h2>
          <p className="mt-2 opacity-90">
            {t('dashboard.candidateSubtitle', 'Complete your profile and tests to increase your visibility to employers.')}
          </p>
        </CardContent>
      </Card>

      {/* Profile Completeness */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <User className="h-5 w-5" />
            {t('dashboard.profileCompleteness', 'Profile Completeness')}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>{profileCompleteness}%</span>
              <span className="text-muted-foreground">
                {profileCompleteness === 100 ? t('dashboard.complete', 'Complete') : t('dashboard.incomplete', 'Incomplete')}
              </span>
            </div>
            <div className="w-full bg-secondary rounded-full h-2">
              <div
                className="bg-primary h-2 rounded-full transition-all"
                style={{ width: `${profileCompleteness}%` }}
              />
            </div>
            {profileCompleteness < 100 && (
              <Button
                variant="link"
                className="p-0 h-auto"
                onClick={() => navigate('/candidate/profile')}
              >
                {t('dashboard.completeProfile', 'Complete your profile')} →
              </Button>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Tests Status */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ClipboardList className="h-5 w-5" />
            {t('dashboard.tests', 'Tests')}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">
                  {testsCompleted} / 6 {t('dashboard.testsCompleted', 'tests completed')}
                </p>
                <p className="text-sm text-muted-foreground mt-1">
                  {testsCompleted === 6
                    ? t('dashboard.allTestsComplete', 'All tests completed!')
                    : t('dashboard.completeRemainingTests', 'Complete remaining tests to improve your profile.')}
                </p>
              </div>
              <Button onClick={() => navigate('/candidate/tests')}>
                {testsCompleted === 0 ? t('dashboard.startTests', 'Start Tests') : t('dashboard.continueTests', 'Continue')}
              </Button>
            </div>

            {testsCompleted === 6 && (
              <Button variant="outline" className="w-full" onClick={() => navigate('/candidate/results')}>
                <Award className="mr-2 h-4 w-4" />
                {t('dashboard.viewResults', 'View Test Results')}
              </Button>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5" />
            {t('dashboard.recentActivity', 'Recent Activity')}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground">
            {t('dashboard.noActivity', 'No recent activity to display.')}
          </p>
        </CardContent>
      </Card>
    </div>
  );
}

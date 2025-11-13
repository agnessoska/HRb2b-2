import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '@/app/providers/auth-provider';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/shared/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/shared/ui/tabs';
import { Button } from '@/shared/ui/button';
import { Input } from '@/shared/ui/input';
import { Label } from '@/shared/ui/label';
import { Separator } from '@/shared/ui/separator';
import { Loader2 } from 'lucide-react';

export function LoginPage() {
  const { t } = useTranslation('auth');
  const { signIn, signUp } = useAuth();
  const navigate = useNavigate();

  // Sign in state
  const [signInEmail, setSignInEmail] = useState('');
  const [signInPassword, setSignInPassword] = useState('');
  const [signInLoading, setSignInLoading] = useState(false);
  const [signInError, setSignInError] = useState('');

  // HR sign up state
  const [hrEmail, setHrEmail] = useState('');
  const [hrPassword, setHrPassword] = useState('');
  const [hrFullName, setHrFullName] = useState('');
  const [hrOrgName, setHrOrgName] = useState('');
  const [hrLoading, setHrLoading] = useState(false);
  const [hrError, setHrError] = useState('');

  // Candidate sign up state
  const [candEmail, setCandEmail] = useState('');
  const [candPassword, setCandPassword] = useState('');
  const [candFullName, setCandFullName] = useState('');
  const [candLoading, setCandLoading] = useState(false);
  const [candError, setCandError] = useState('');

  // Handle sign in
  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setSignInLoading(true);
    setSignInError('');

    try {
      await signIn(signInEmail, signInPassword);
      // Navigation will be handled by auth state change
    } catch (error: any) {
      setSignInError(error.message || t('signIn.error'));
    } finally {
      setSignInLoading(false);
    }
  };

  // Handle HR sign up
  const handleHRSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setHrLoading(true);
    setHrError('');

    try {
      await signUp(hrEmail, hrPassword, 'hr_specialist', {
        full_name: hrFullName,
        organization_name: hrOrgName,
      });
      setHrError(''); // Success message will be shown by auth provider
      alert(t('signUp.hr.success'));
    } catch (error: any) {
      setHrError(error.message || t('signUp.hr.error'));
    } finally {
      setHrLoading(false);
    }
  };

  // Handle Candidate sign up
  const handleCandidateSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setCandLoading(true);
    setCandError('');

    try {
      await signUp(candEmail, candPassword, 'candidate', {
        full_name: candFullName,
      });
      setCandError('');
      alert(t('signUp.candidate.success'));
    } catch (error: any) {
      setCandError(error.message || t('signUp.candidate.error'));
    } finally {
      setCandLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-2xl">{t('title')}</CardTitle>
        <CardDescription>{t('subtitle')}</CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="signin" className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="signin">{t('tabs.signIn')}</TabsTrigger>
            <TabsTrigger value="hr">{t('tabs.hrSignUp')}</TabsTrigger>
            <TabsTrigger value="candidate">{t('tabs.candidateSignUp')}</TabsTrigger>
          </TabsList>

          {/* Sign In Tab */}
          <TabsContent value="signin">
            <form onSubmit={handleSignIn} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="signin-email">{t('signIn.email')}</Label>
                <Input
                  id="signin-email"
                  type="email"
                  placeholder="hr@example.com"
                  value={signInEmail}
                  onChange={(e) => setSignInEmail(e.target.value)}
                  required
                  disabled={signInLoading}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="signin-password">{t('signIn.password')}</Label>
                <Input
                  id="signin-password"
                  type="password"
                  value={signInPassword}
                  onChange={(e) => setSignInPassword(e.target.value)}
                  required
                  disabled={signInLoading}
                />
              </div>

              {signInError && (
                <p className="text-sm text-red-600 dark:text-red-400">{signInError}</p>
              )}

              <Button type="submit" className="w-full" disabled={signInLoading}>
                {signInLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {t('signIn.button')}
              </Button>

              <div className="text-center">
                <Button variant="link" size="sm" onClick={() => navigate('/auth/forgot-password')}>
                  {t('signIn.forgotPassword')}
                </Button>
              </div>
            </form>
          </TabsContent>

          {/* HR Sign Up Tab */}
          <TabsContent value="hr">
            <form onSubmit={handleHRSignUp} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="hr-fullname">{t('signUp.hr.fullName')}</Label>
                <Input
                  id="hr-fullname"
                  type="text"
                  placeholder={t('signUp.hr.fullNamePlaceholder')}
                  value={hrFullName}
                  onChange={(e) => setHrFullName(e.target.value)}
                  required
                  disabled={hrLoading}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="hr-orgname">{t('signUp.hr.orgName')}</Label>
                <Input
                  id="hr-orgname"
                  type="text"
                  placeholder={t('signUp.hr.orgNamePlaceholder')}
                  value={hrOrgName}
                  onChange={(e) => setHrOrgName(e.target.value)}
                  required
                  disabled={hrLoading}
                />
              </div>

              <Separator />

              <div className="space-y-2">
                <Label htmlFor="hr-email">{t('signUp.hr.email')}</Label>
                <Input
                  id="hr-email"
                  type="email"
                  placeholder="hr@company.com"
                  value={hrEmail}
                  onChange={(e) => setHrEmail(e.target.value)}
                  required
                  disabled={hrLoading}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="hr-password">{t('signUp.hr.password')}</Label>
                <Input
                  id="hr-password"
                  type="password"
                  placeholder={t('signUp.hr.passwordPlaceholder')}
                  value={hrPassword}
                  onChange={(e) => setHrPassword(e.target.value)}
                  required
                  disabled={hrLoading}
                  minLength={6}
                />
                <p className="text-xs text-muted-foreground">
                  {t('signUp.passwordHint')}
                </p>
              </div>

              {hrError && (
                <p className="text-sm text-red-600 dark:text-red-400">{hrError}</p>
              )}

              <Button type="submit" className="w-full" disabled={hrLoading}>
                {hrLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {t('signUp.hr.button')}
              </Button>

              <p className="text-xs text-center text-muted-foreground">
                {t('signUp.hr.tokenBonus')}
              </p>
            </form>
          </TabsContent>

          {/* Candidate Sign Up Tab */}
          <TabsContent value="candidate">
            <form onSubmit={handleCandidateSignUp} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="cand-fullname">{t('signUp.candidate.fullName')}</Label>
                <Input
                  id="cand-fullname"
                  type="text"
                  placeholder={t('signUp.candidate.fullNamePlaceholder')}
                  value={candFullName}
                  onChange={(e) => setCandFullName(e.target.value)}
                  required
                  disabled={candLoading}
                />
              </div>

              <Separator />

              <div className="space-y-2">
                <Label htmlFor="cand-email">{t('signUp.candidate.email')}</Label>
                <Input
                  id="cand-email"
                  type="email"
                  placeholder="candidate@example.com"
                  value={candEmail}
                  onChange={(e) => setCandEmail(e.target.value)}
                  required
                  disabled={candLoading}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="cand-password">{t('signUp.candidate.password')}</Label>
                <Input
                  id="cand-password"
                  type="password"
                  placeholder={t('signUp.candidate.passwordPlaceholder')}
                  value={candPassword}
                  onChange={(e) => setCandPassword(e.target.value)}
                  required
                  disabled={candLoading}
                  minLength={6}
                />
                <p className="text-xs text-muted-foreground">
                  {t('signUp.passwordHint')}
                </p>
              </div>

              {candError && (
                <p className="text-sm text-red-600 dark:text-red-400">{candError}</p>
              )}

              <Button type="submit" className="w-full" disabled={candLoading}>
                {candLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {t('signUp.candidate.button')}
              </Button>

              <p className="text-xs text-center text-muted-foreground">
                {t('signUp.candidate.note')}
              </p>
            </form>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
}

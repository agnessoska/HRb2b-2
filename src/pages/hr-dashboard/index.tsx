import { useTranslation } from 'react-i18next';
import { Card, CardContent, CardHeader, CardTitle } from '@/shared/ui/card';
import { Users, Briefcase, Coins, MessageSquare } from 'lucide-react';
import { useAuth } from '@/app/providers/auth-provider';

export function HRDashboardPage() {
  const { t } = useTranslation('common');
  const { organization } = useAuth();

  const stats = [
    {
      title: t('stats.totalCandidates', 'Total Candidates'),
      value: '0',
      icon: Users,
      color: 'text-blue-600',
    },
    {
      title: t('stats.activeVacancies', 'Active Vacancies'),
      value: '0',
      icon: Briefcase,
      color: 'text-purple-600',
    },
    {
      title: t('stats.tokenBalance', 'Token Balance'),
      value: organization?.token_balance.toLocaleString() || '0',
      icon: Coins,
      color: 'text-amber-600',
    },
    {
      title: t('stats.unreadMessages', 'Unread Messages'),
      value: '0',
      icon: MessageSquare,
      color: 'text-green-600',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight">
          {t('dashboard.welcome', 'Welcome back!')}
        </h1>
        <p className="text-muted-foreground mt-2">
          {t('dashboard.hrSubtitle', "Here's what's happening with your recruitment today.")}
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  {stat.title}
                </CardTitle>
                <Icon className={`h-4 w-4 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Placeholder content */}
      <Card>
        <CardHeader>
          <CardTitle>{t('dashboard.recentActivity', 'Recent Activity')}</CardTitle>
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

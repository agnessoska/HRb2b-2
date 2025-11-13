import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuth } from '@/app/providers/auth-provider';
import { cn } from '@/shared/lib/utils';
import {
  LayoutDashboard,
  Briefcase,
  Users,
  Target,
  MessageSquare,
  ClipboardList,
  Award,
  User,
} from 'lucide-react';

interface NavItem {
  href: string;
  label: string;
  icon: React.ReactNode;
  badge?: number;
}

export function Sidebar() {
  const { t } = useTranslation('common');
  const { role } = useAuth();
  const location = useLocation();

  // HR navigation items
  const hrNavItems: NavItem[] = [
    {
      href: '/hr/dashboard',
      label: t('nav.dashboard'),
      icon: <LayoutDashboard className="h-5 w-5" />,
    },
    {
      href: '/hr/vacancies',
      label: t('nav.vacancies'),
      icon: <Briefcase className="h-5 w-5" />,
    },
    {
      href: '/hr/candidates',
      label: t('nav.candidates'),
      icon: <Users className="h-5 w-5" />,
    },
    {
      href: '/hr/talent-market',
      label: t('nav.talentMarket'),
      icon: <Target className="h-5 w-5" />,
    },
    {
      href: '/hr/chat',
      label: t('nav.chat'),
      icon: <MessageSquare className="h-5 w-5" />,
    },
  ];

  // Candidate navigation items
  const candidateNavItems: NavItem[] = [
    {
      href: '/candidate/dashboard',
      label: t('nav.dashboard'),
      icon: <LayoutDashboard className="h-5 w-5" />,
    },
    {
      href: '/candidate/tests',
      label: t('nav.tests'),
      icon: <ClipboardList className="h-5 w-5" />,
    },
    {
      href: '/candidate/results',
      label: t('nav.results'),
      icon: <Award className="h-5 w-5" />,
    },
    {
      href: '/candidate/profile',
      label: t('nav.profile'),
      icon: <User className="h-5 w-5" />,
    },
    {
      href: '/candidate/chat',
      label: t('nav.chat'),
      icon: <MessageSquare className="h-5 w-5" />,
    },
  ];

  const navItems = role === 'hr_specialist' ? hrNavItems : candidateNavItems;

  return (
    <aside className="w-[280px] border-r bg-background hidden lg:block">
      <nav className="flex flex-col gap-1 p-4">
        {navItems.map((item) => {
          const isActive = location.pathname === item.href;

          return (
            <Link
              key={item.href}
              to={item.href}
              className={cn(
                'flex items-center gap-3 px-3 py-2 rounded-lg transition-colors',
                'hover:bg-accent hover:text-accent-foreground',
                isActive && 'bg-accent text-accent-foreground font-medium'
              )}
            >
              {item.icon}
              <span className="flex-1">{item.label}</span>
              {item.badge && (
                <span className="flex h-5 w-5 items-center justify-center rounded-full bg-primary text-xs text-primary-foreground">
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}

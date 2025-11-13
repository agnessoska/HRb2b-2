import { Building2, Menu, Coins } from 'lucide-react';
import { useAuth } from '@/app/providers/auth-provider';
import { ThemeToggle } from './theme-toggle';
import { Button } from '@/shared/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/shared/ui/dropdown-menu';
import { Avatar, AvatarFallback } from '@/shared/ui/avatar';

interface HeaderProps {
  onMenuClick?: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  const { authUser, role, organization, signOut } = useAuth();

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const profileName = authUser?.profile
    ? 'full_name' in authUser.profile
      ? authUser.profile.full_name
      : ''
    : '';

  return (
    <header className="sticky top-0 z-40 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="flex h-16 items-center justify-between px-4 lg:px-6">
        {/* Left: Menu + Logo/Name */}
        <div className="flex items-center gap-3">
          {/* Mobile menu button */}
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden"
            onClick={onMenuClick}
          >
            <Menu className="h-5 w-5" />
          </Button>

          {/* Logo and organization name */}
          <div className="flex items-center gap-3">
            {organization?.logo_url ? (
              <img
                src={organization.logo_url}
                alt={organization.name}
                className="h-8 w-auto"
              />
            ) : (
              <Building2 className="h-8 w-8 text-primary" />
            )}
            <h1 className="text-xl font-semibold hidden md:block">
              {organization?.name || 'HR Platform'}
            </h1>
          </div>
        </div>

        {/* Right: Token Balance (HR only) + Theme Toggle + User Menu */}
        <div className="flex items-center gap-3">
          {/* Token Balance - only for HR specialists */}
          {role === 'hr_specialist' && organization && (
            <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50 dark:bg-amber-950 border border-amber-200 dark:border-amber-900">
              <Coins className="h-4 w-4 text-amber-600 dark:text-amber-400" />
              <span className="text-sm font-medium text-amber-900 dark:text-amber-100">
                {organization.token_balance.toLocaleString()}
              </span>
            </div>
          )}

          {/* Theme Toggle */}
          <ThemeToggle />

          {/* User Menu */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="relative h-10 w-10 rounded-full">
                <Avatar>
                  <AvatarFallback>
                    {profileName ? getInitials(profileName) : 'U'}
                  </AvatarFallback>
                </Avatar>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <div className="flex items-center justify-start gap-2 p-2">
                <div className="flex flex-col space-y-1">
                  <p className="text-sm font-medium">{profileName}</p>
                  <p className="text-xs text-muted-foreground">
                    {authUser?.user.email}
                  </p>
                </div>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={() => window.location.href = `/${role}/profile`}>
                Profile Settings
              </DropdownMenuItem>
              {role === 'hr_specialist' && (
                <DropdownMenuItem onClick={() => window.location.href = '/hr/organization'}>
                  Organization
                </DropdownMenuItem>
              )}
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={signOut} className="text-red-600 dark:text-red-400">
                Sign Out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}

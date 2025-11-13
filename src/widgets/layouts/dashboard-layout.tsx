import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import { Header } from '@/widgets/header/header';
import { Sidebar } from '@/widgets/sidebar/sidebar';
import { Sheet, SheetContent } from '@/shared/ui/sheet';
import { Sidebar as MobileSidebar } from '@/widgets/sidebar/sidebar';

export function DashboardLayout() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <Header onMenuClick={() => setMobileMenuOpen(true)} />

      {/* Content with Sidebar */}
      <div className="flex-1 flex">
        {/* Desktop Sidebar */}
        <Sidebar />

        {/* Mobile Sidebar (Sheet) */}
        <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
          <SheetContent side="left" className="p-0 w-[280px]">
            <MobileSidebar />
          </SheetContent>
        </Sheet>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto">
          <div className="container py-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}

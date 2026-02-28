import { Outlet, useLocation, NavLink } from 'react-router-dom';
import { Header } from './Header';
import { Shirt, LayoutGrid, Sparkles, Wand2 } from 'lucide-react';
import { useAuth } from '@/hooks/useAuth';
import { cn } from '@/utils/cn';

const BOTTOM_NAV = [
  { to: '/wardrobe', label: 'Wardrobe', icon: Shirt },
  { to: '/outfits', label: 'Outfits', icon: LayoutGrid },
  { to: '/recommendations', label: 'Picks', icon: Sparkles },
  { to: '/tryon', label: 'Try-On', icon: Wand2 },
];

export const Layout = () => {
  const { isAuthenticated } = useAuth();
  const location = useLocation();
  const isHome = location.pathname === '/';

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Header />
      <main className={cn('flex-1', isAuthenticated && !isHome && 'pb-16 md:pb-0')}>
        <Outlet />
      </main>

      {/* Mobile bottom tab bar */}
      {isAuthenticated && !isHome && (
        <nav className="md:hidden fixed bottom-0 left-0 right-0 z-30 bg-white border-t border-gray-200">
          <div className="flex items-center justify-around h-16">
            {BOTTOM_NAV.map(({ to, label, icon: Icon }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) =>
                  cn(
                    'flex flex-col items-center gap-0.5 flex-1 py-2 text-xs font-medium transition-colors',
                    isActive ? 'text-primary-600' : 'text-gray-400'
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <div className={cn('p-1.5 rounded-xl transition-all', isActive && 'bg-primary-50')}>
                      <Icon className="h-5 w-5" />
                    </div>
                    <span>{label}</span>
                  </>
                )}
              </NavLink>
            ))}
          </div>
        </nav>
      )}
    </div>
  );
};

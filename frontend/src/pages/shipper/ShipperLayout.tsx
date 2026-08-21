import { ReactNode } from 'react';
import { NavLink, useNavigate, useLocation } from 'react-router-dom';
import { clearSession, getStoredUser } from '../../services/authService';

interface ShipperLayoutProps {
  children?: ReactNode;
}

const SHIPPER_NAV = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/shipments/create', label: 'Find Truck', icon: '🔍' },
  { path: '/shipments', label: 'Requests', icon: '📋' },
  { path: '/bids', label: 'Bids', icon: '🏷️' },
  { path: '/messages', label: 'Messages', icon: '💬' },
  { path: '/tracking', label: 'Deliveries', icon: '🚛' },
  { path: '/history', label: 'History', icon: '🗂️' },
  { path: '/ratings', label: 'Ratings', icon: '⭐' },
  { path: '/profile', label: 'Profile', icon: '👤' },
];

export default function ShipperLayout({ children }: ShipperLayoutProps) {
  const navigate = useNavigate();
  const location = useLocation();
  const user = getStoredUser();

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  const displayName = user?.full_name || 'Shipper Partner';

  const initials = displayName
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans">
      {/* ── Sidebar (Fixed) ── */}
      <aside className="fixed top-0 bottom-0 left-0 w-[260px] bg-[#071426] text-white flex flex-col z-50 transition-transform duration-300 ease-in-out">
        {/* Brand */}
        <div className="p-6 border-b border-white/10">
          <div className="flex items-center gap-1 cursor-pointer" onClick={() => navigate('/dashboard')}>
            <span className="text-[#C8933A] font-bold text-[1.35rem] tracking-tight">Habesha</span>
            <span className="text-white font-bold text-[1.35rem] tracking-tight">Freight</span>
          </div>
          <div className="text-xs text-white/50 mt-1 uppercase tracking-wider">
            Shipper Account
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto p-4 flex flex-col gap-1">
          {SHIPPER_NAV.map((item) => {
            if (item.path === '/shipments/create') {
              return (
                <div key="find-truck-group" className="flex flex-col gap-1">
                  <NavLink
                    to="/shipments/create"
                    className={({ isActive }) =>
                      `flex items-center gap-3 px-4 py-3 rounded-lg text-sm transition-all duration-200 ${
                        isActive || location.pathname === '/fleet'
                          ? 'bg-[#1A2E46] text-white font-semibold'
                          : 'text-white/60 font-normal hover:bg-white/5 hover:text-white'
                      }`
                    }
                  >
                    <span className="text-lg">🔍</span>
                    <span>Find Truck</span>
                  </NavLink>

                  {/* Sub-menu items */}
                  <div className="flex flex-col gap-1 pl-9 pr-2 py-1">
                    <NavLink
                      to="/shipments/create"
                      className={({ isActive }) =>
                        `flex items-center gap-2 px-3 py-2 rounded-md text-xs transition-all ${
                          isActive
                            ? 'bg-[#2B4365] text-white font-semibold'
                            : 'text-white/50 hover:text-white hover:bg-white/5'
                        }`
                      }
                    >
                      <span>🚛</span>
                      <span>Single Truck</span>
                    </NavLink>
                    <NavLink
                      to="/fleet"
                      className={({ isActive }) =>
                        `flex items-center gap-2 px-3 py-2 rounded-md text-xs transition-all ${
                          isActive
                            ? 'bg-[#2B4365] text-white font-semibold'
                            : 'text-white/50 hover:text-white hover:bg-white/5'
                        }`
                      }
                    >
                      <span>🏢</span>
                      <span>Multiple Trucks</span>
                    </NavLink>
                  </div>
                </div>
              );
            }

            return (
              <NavLink
                key={item.path}
                to={item.path}
                end={item.path === '/dashboard'}
                className={({ isActive }) =>
                  `flex items-center gap-3 px-4 py-3 rounded-lg text-sm transition-all duration-200 ${
                    isActive
                      ? 'bg-[#1A2E46] text-white font-semibold'
                      : 'text-white/60 font-normal hover:bg-white/5 hover:text-white'
                  }`
                }
              >
                <span className="text-lg">{item.icon}</span>
                <span>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>

        {/* Sidebar Footer / User Widget */}
        <div className="p-5 border-t border-white/10 bg-[#05101F]">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-full bg-[#C8933A] text-white font-bold flex items-center justify-center text-sm">
              {initials}
            </div>
            <div>
              <div className="font-semibold text-sm text-white">{displayName}</div>
              <div className="text-xs text-white/50 capitalize">{user?.role?.toLowerCase() ?? 'Shipper'}</div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="text-xs text-white/50 hover:text-white transition-colors flex items-center gap-1.5 p-0 bg-transparent border-none cursor-pointer"
          >
            ← Log Out
          </button>
        </div>
      </aside>

      {/* ── Main Content Area (Margin Left for Sidebar) ── */}
      <div className="ml-[260px] flex-1 flex flex-col min-w-0">
        <div className="flex-1">
          {children}
        </div>
      </div>
    </div>
  );
}

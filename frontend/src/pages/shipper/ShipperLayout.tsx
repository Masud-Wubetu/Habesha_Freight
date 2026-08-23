import { ReactNode, useEffect, useState } from 'react';
import { NavLink, useNavigate, useLocation } from 'react-router-dom';
import { clearSession, getStoredUser } from '../../services/authService';
import { getTheme, toggleTheme } from '../../services/themeService';

interface ShipperLayoutProps {
  children?: ReactNode;
}

const SHIPPER_NAV = [
  { path: '/dashboard', label: 'Dashboard', icon: '📊' },
  { path: '/shipments/create', label: 'Find Truck', icon: '🔍' },
  { path: '/shipments', label: 'Requests', icon: '📋' },
  { path: '/bids', label: 'Bids', icon: '🏷️' },
  { path: '/payments', label: 'Escrow & Payments', icon: '💳' },
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

  // Resizable & Collapsible Sidebar State
  const [sidebarWidth, setSidebarWidth] = useState<number>(() => {
    const saved = localStorage.getItem('shipper_sidebar_width');
    return saved ? Math.min(420, Math.max(180, Number(saved))) : 260;
  });
  const [isResizing, setIsResizing] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  // Drag Resizing Logic
  const startResizing = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsResizing(true);
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isResizing) return;
      const newWidth = Math.min(420, Math.max(180, e.clientX));
      setSidebarWidth(newWidth);
      localStorage.setItem('shipper_sidebar_width', String(newWidth));
    };

    const handleMouseUp = () => {
      if (isResizing) {
        setIsResizing(false);
      }
    };

    if (isResizing) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);
    }
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isResizing]);

  const displayName = user?.full_name || 'Shipper Partner';

  const initials = displayName
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  const currentWidth = isCollapsed ? 72 : sidebarWidth;

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans">
      {/* ── Sidebar (Fixed & Resizable) ── */}
      <aside
        className="fixed top-0 bottom-0 left-0 bg-[#071426] text-white flex flex-col z-50 no-scrollbar admin-sidebar-nav"
        style={{
          width: `${currentWidth}px`,
          transition: isResizing ? 'none' : 'width 0.2s ease',
          userSelect: isResizing ? 'none' : 'auto',
          position: 'fixed',
        }}
      >
        {/* Drag-to-Resize Right Edge Handle */}
        {!isCollapsed && (
          <div
            onMouseDown={startResizing}
            style={{
              position: 'absolute',
              right: 0,
              top: 0,
              bottom: 0,
              width: '6px',
              cursor: 'col-resize',
              zIndex: 110,
              backgroundColor: isResizing ? '#C8933A' : 'transparent',
              transition: 'background-color 0.2s ease',
            }}
            title="Drag left/right to resize sidebar width"
          />
        )}

        {/* Brand Header & Collapse Toggle Button */}
        <div className={`p-5 border-b border-white/10 flex items-center ${isCollapsed ? 'justify-center' : 'justify-between'}`}>
          {!isCollapsed && (
            <div>
              <div className="flex items-center gap-1 cursor-pointer" onClick={() => navigate('/dashboard')}>
                <span className="text-[#C8933A] font-bold text-[1.35rem] tracking-tight">Habesha</span>
                <span className="text-white font-bold text-[1.35rem] tracking-tight">Freight</span>
              </div>
              <div className="text-xs text-white/50 mt-1 uppercase tracking-wider">
                Shipper Account
              </div>
            </div>
          )}

          {/* Desktop Collapse / Expand Button */}
          <button
            onClick={() => setIsCollapsed(!isCollapsed)}
            style={{
              backgroundColor: 'rgba(255,255,255,0.08)',
              border: 'none',
              borderRadius: '0.35rem',
              color: '#FFFFFF',
              width: '28px',
              height: '28px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              fontSize: '0.9rem',
            }}
            title={isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
          >
            {isCollapsed ? '»' : '«'}
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto p-4 flex flex-col gap-1 no-scrollbar" style={{ msOverflowStyle: 'none', scrollbarWidth: 'none' }}>
          {SHIPPER_NAV.map((item) => {
            if (item.path === '/shipments/create') {
              return (
                <div key="find-truck-group" className="flex flex-col gap-1">
                  <NavLink
                    to="/shipments/create"
                    title={isCollapsed ? 'Find Truck' : undefined}
                    className={({ isActive }) =>
                      `flex items-center ${isCollapsed ? 'justify-center' : 'gap-3 px-4'} py-3 rounded-lg text-sm transition-all duration-200 ${
                        isActive || location.pathname === '/fleet'
                          ? 'bg-[#1A2E46] text-white font-semibold'
                          : 'text-white/60 font-normal hover:bg-white/5 hover:text-white'
                      }`
                    }
                  >
                    <span className="text-lg">🔍</span>
                    {!isCollapsed && <span>Find Truck</span>}
                  </NavLink>

                  {/* Sub-menu items */}
                  {!isCollapsed && (
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
                  )}
                </div>
              );
            }

            return (
              <NavLink
                key={item.path}
                to={item.path}
                end={item.path === '/dashboard'}
                title={isCollapsed ? item.label : undefined}
                className={({ isActive }) =>
                  `flex items-center ${isCollapsed ? 'justify-center' : 'gap-3 px-4'} py-3 rounded-lg text-sm transition-all duration-200 ${
                    isActive
                      ? 'bg-[#1A2E46] text-white font-semibold'
                      : 'text-white/60 font-normal hover:bg-white/5 hover:text-white'
                  }`
                }
              >
                <span className="text-lg">{item.icon}</span>
                {!isCollapsed && <span className="truncate">{item.label}</span>}
              </NavLink>
            );
          })}
        </nav>

        {/* Sidebar Footer / User Widget */}
        <div className={`p-4 border-t border-white/10 bg-[#05101F] ${isCollapsed ? 'text-center' : ''}`}>
          <div className={`flex items-center gap-3 ${isCollapsed ? 'justify-center' : 'mb-3'}`}>
            <div className="w-9 h-9 rounded-full bg-[#C8933A] text-white font-bold flex items-center justify-center text-sm flex-shrink-0" title={displayName}>
              {initials}
            </div>
            {!isCollapsed && (
              <div className="min-w-0 flex-1">
                <div className="font-semibold text-sm text-white truncate">{displayName}</div>
                <div className="text-xs text-white/50 capitalize">{user?.role?.toLowerCase() ?? 'Shipper'}</div>
              </div>
            )}
          </div>
          {!isCollapsed && (
            <button
              onClick={handleLogout}
              className="text-xs text-white/50 hover:text-white transition-colors flex items-center gap-1.5 p-0 bg-transparent border-none cursor-pointer"
            >
              ← Log Out
            </button>
          )}
        </div>
      </aside>

      {/* ── Main Content Area (Margin Left for Sidebar) ── */}
      <div
        className="flex-1 flex flex-col min-w-0"
        style={{
          marginLeft: `${currentWidth}px`,
          transition: isResizing ? 'none' : 'margin-left 0.2s ease',
        }}
      >
        {/* Top Header Navigation Bar */}
        <header
          className="h-[60px] px-8 flex items-center justify-between sticky top-0 z-40 border-b transition-all duration-200"
          style={{
            backgroundColor: getTheme() === 'dark' ? '#0D1E30' : '#FFFFFF',
            borderColor: getTheme() === 'dark' ? 'rgba(255,255,255,0.1)' : '#E2E8F0',
          }}
        >
          <div className="flex items-center gap-2">
            <span className="text-sm font-semibold text-slate-500">
              Shipper Control Portal
            </span>
          </div>

          <div className="flex items-center gap-4">
            <button
              onClick={() => {
                toggleTheme();
                window.dispatchEvent(new Event('storage'));
              }}
              className="bg-slate-900 text-white dark:bg-slate-800 border-none rounded-full px-4 py-1.5 text-xs font-bold cursor-pointer flex items-center gap-2 shadow-sm transition-all hover:opacity-90"
              title="Toggle Light/Dark Theme"
            >
              <span>🌙 / ☀️</span>
              <span>Toggle Dark Mode</span>
            </button>

            <div className="w-8 h-8 rounded-full bg-[#C8933A] text-white font-bold flex items-center justify-center text-xs">
              {initials}
            </div>
          </div>
        </header>

        <div className="flex-1">
          {children}
        </div>
      </div>
    </div>
  );
}

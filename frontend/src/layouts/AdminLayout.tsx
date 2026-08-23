import { ReactNode, useEffect, useState } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import { clearSession, getStoredUser } from '../services/authService';
import { getTheme, toggleTheme } from '../services/themeService';

interface AdminLayoutProps {
  children: ReactNode;
}

const adminNavItems = [
  { path: '/admin', label: 'Overview', icon: '📊' },
  { path: '/admin/users', label: 'Users', icon: '👥' },
  { path: '/admin/drivers', label: 'Drivers', icon: '🚛' },
  { path: '/admin/companies', label: 'Transport Companies', icon: '🏢' },
  { path: '/admin/vehicles', label: 'Vehicles', icon: '🚚' },
  { path: '/admin/deliveries', label: 'Deliveries', icon: '📦' },
  { path: '/admin/verification', label: 'Verification', icon: '✅' },
  { path: '/admin/payments', label: 'Payments / Escrow', icon: '💳' },
  { path: '/admin/disputes', label: 'Disputes', icon: '⚠️' },
  { path: '/admin/reports', label: 'Reports', icon: '📈' },
  { path: '/admin/audit-logs', label: 'Audit Logs', icon: '📋' },
];

export default function AdminLayout({ children }: AdminLayoutProps) {
  const navigate = useNavigate();
  const user = getStoredUser();
  const [themeMode, setThemeMode] = useState<'light' | 'dark'>(getTheme());

  // Resizable & Collapsible Sidebar State
  const [sidebarWidth, setSidebarWidth] = useState<number>(() => {
    const saved = localStorage.getItem('admin_sidebar_width');
    return saved ? Math.min(420, Math.max(180, Number(saved))) : 260;
  });
  const [isResizing, setIsResizing] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);

  const handleToggleTheme = () => {
    const next = toggleTheme();
    setThemeMode(next);
  };

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
      localStorage.setItem('admin_sidebar_width', String(newWidth));
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

  const currentWidth = isCollapsed ? 72 : sidebarWidth;

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#F4F6F9', fontFamily: 'DM Sans, sans-serif' }}>
      {/* Resizable / Collapsible Sidebar */}
      <aside
        style={{
          width: `${currentWidth}px`,
          backgroundColor: '#071426',
          color: '#FFFFFF',
          display: 'flex',
          flexDirection: 'column',
          position: 'fixed',
          top: 0,
          bottom: 0,
          left: 0,
          zIndex: 100,
          transition: isResizing ? 'none' : 'width 0.2s ease',
          userSelect: isResizing ? 'none' : 'auto',
          boxShadow: '2px 0 10px rgba(0,0,0,0.15)',
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

        {/* Brand Header & Collapse Button */}
        <div
          style={{
            padding: isCollapsed ? '1.25rem 0.5rem' : '1.5rem 1.25rem 1.25rem 1.25rem',
            borderBottom: '1px solid rgba(255,255,255,0.08)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: isCollapsed ? 'center' : 'space-between',
          }}
        >
          {!isCollapsed && (
            <div>
              <Link to="/admin" style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                <span style={{ color: '#C8933A', fontWeight: 700, fontSize: '1.35rem', letterSpacing: '-0.02em' }}>Habesha</span>
                <span style={{ color: '#FFFFFF', fontWeight: 700, fontSize: '1.35rem', letterSpacing: '-0.02em' }}>Freight</span>
              </Link>
              <div style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.5)', marginTop: '0.2rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                Admin Console
              </div>
            </div>
          )}

          {/* Collapse / Expand Toggle Icon */}
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
              transition: 'all 0.2s ease',
            }}
            title={isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
          >
            {isCollapsed ? '»' : '«'}
          </button>
        </div>

        {/* Navigation List */}
        <nav
          className="no-scrollbar admin-sidebar-nav"
          style={{
            flex: 1,
            padding: isCollapsed ? '1rem 0.35rem' : '1rem 0.75rem',
            overflowY: 'auto',
            msOverflowStyle: 'none',
            scrollbarWidth: 'none',
          }}
        >
          {adminNavItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/admin'}
              title={isCollapsed ? item.label : undefined}
              style={({ isActive }: { isActive: boolean }) => ({
                display: 'flex',
                alignItems: 'center',
                justifyContent: isCollapsed ? 'center' : 'flex-start',
                gap: isCollapsed ? 0 : '0.85rem',
                padding: '0.7rem 0.85rem',
                margin: '0.25rem 0',
                borderRadius: '0.5rem',
                textDecoration: 'none',
                fontSize: '0.925rem',
                fontWeight: isActive ? 600 : 400,
                color: isActive ? '#FFFFFF' : 'rgba(255,255,255,0.65)',
                backgroundColor: isActive ? '#1A2E46' : 'transparent',
                transition: 'all 0.2s ease',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              })}
            >
              <span style={{ fontSize: '1.1rem', flexShrink: 0 }}>{item.icon}</span>
              {!isCollapsed && <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>{item.label}</span>}
            </NavLink>
          ))}
        </nav>

        {/* Sidebar Footer / User Widget */}
        <div style={{ padding: isCollapsed ? '0.75rem 0.25rem' : '1.25rem', borderTop: '1px solid rgba(255,255,255,0.08)', backgroundColor: '#05101F' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: isCollapsed ? 'center' : 'flex-start', gap: '0.75rem', marginBottom: isCollapsed ? 0 : '0.75rem' }}>
            <div
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.875rem',
                flexShrink: 0,
              }}
              title={user?.full_name || 'Admin'}
            >
              {(user?.full_name ?? 'Admin').split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase() || 'AD'}
            </div>
            {!isCollapsed && (
              <div style={{ minWidth: 0, flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: '0.875rem', color: '#FFFFFF', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {user?.full_name || 'Admin'}
                </div>
                <div style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.5)' }}>Super Admin</div>
              </div>
            )}
          </div>

          {!isCollapsed && (
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <button
                onClick={handleLogout}
                style={{
                  background: 'none',
                  border: 'none',
                  color: 'rgba(255,255,255,0.5)',
                  fontSize: '0.825rem',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.35rem',
                  padding: 0,
                }}
              >
                ← Log Out
              </button>

              <button
                onClick={handleToggleTheme}
                style={{
                  background: 'rgba(255,255,255,0.1)',
                  border: 'none',
                  borderRadius: '0.4rem',
                  color: '#FFFFFF',
                  fontSize: '0.8rem',
                  fontWeight: 600,
                  padding: '0.3rem 0.6rem',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.35rem',
                }}
                title="Toggle Light/Dark Theme"
              >
                {themeMode === 'dark' ? '☀️ Light' : '🌙 Dark'}
              </button>
            </div>
          )}
        </div>
      </aside>

      {/* Main Content Area */}
      <div
        style={{
          marginLeft: `${currentWidth}px`,
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          minWidth: 0,
          transition: isResizing ? 'none' : 'margin-left 0.2s ease',
        }}
      >
        {/* Top Header Navigation Bar */}
        <header
          style={{
            height: '60px',
            backgroundColor: themeMode === 'dark' ? '#0D1E30' : '#FFFFFF',
            borderBottom: '1px solid',
            borderColor: themeMode === 'dark' ? 'rgba(255,255,255,0.1)' : '#E2E8F0',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '0 2.5rem',
            position: 'sticky',
            top: 0,
            zIndex: 90,
            transition: 'all 0.2s ease',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: themeMode === 'dark' ? '#94A3B8' : '#64748B' }}>
              Habesha Freight Control Console
            </span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            {/* Top Prominent Dark Mode Toggle Button */}
            <button
              onClick={handleToggleTheme}
              style={{
                backgroundColor: themeMode === 'dark' ? '#1E293B' : '#0F172A',
                color: '#FFFFFF',
                border: 'none',
                borderRadius: '2rem',
                padding: '0.45rem 1rem',
                fontSize: '0.825rem',
                fontWeight: 700,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
                transition: 'all 0.2s ease',
              }}
              title="Toggle Light/Dark Theme"
            >
              <span>{themeMode === 'dark' ? '☀️' : '🌙'}</span>
              <span>{themeMode === 'dark' ? 'Light Mode' : 'Dark Mode'}</span>
            </button>

            {/* Profile Avatar */}
            <div
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.85rem',
              }}
            >
              {(user?.full_name ?? 'Admin').split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase() || 'AD'}
            </div>
          </div>
        </header>

        {children}
      </div>
    </div>
  );
}

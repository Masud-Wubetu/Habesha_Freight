import { ReactNode, useState, useEffect } from 'react';
import { Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import { clearSession, getStoredUser } from '../services/authService';
import { toggleTheme } from '../services/themeService';
import '../styles/driver-layout.css';

interface DriverLayoutProps {
  children: ReactNode;
}

const NAV_ITEMS = [
  { path: '/driver/dashboard',        icon: '📊', label: 'Dashboard'       },
  { path: '/driver/requests',         icon: '🔍', label: 'Requests'        },
  { path: '/driver/bids',             icon: '💰', label: 'My Bids'         },
  { path: '/driver/active-delivery',  icon: '🚛', label: 'Active Delivery' },
  { path: '/driver/wallet',           icon: '💳', label: 'Wallet & Payouts'},
  { path: '/driver/history',          icon: '🗂️', label: 'History'         },
  { path: '/driver/messages',         icon: '💬', label: 'Messages'        },
  { path: '/driver/ratings',          icon: '⭐', label: 'Ratings'         },
  { path: '/driver/profile',          icon: '👤', label: 'Profile'         },
];

export default function DriverLayout({ children }: DriverLayoutProps) {
  // Start open on desktop, closed on mobile
  const [sidebarOpen, setSidebarOpen] = useState(() => window.innerWidth >= 769);

  const navigate  = useNavigate();
  const location  = useLocation();
  const user      = getStoredUser();

  // Resizable & Collapsible Sidebar State
  const [sidebarWidth, setSidebarWidth] = useState<number>(() => {
    const saved = localStorage.getItem('driver_sidebar_width');
    return saved ? Math.min(420, Math.max(180, Number(saved))) : 260;
  });
  const [isResizing, setIsResizing] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);

  const initials = (user?.full_name ?? 'AG')
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  // Close sidebar on mobile when route changes
  useEffect(() => {
    if (window.innerWidth < 769) setSidebarOpen(false);
  }, [location.pathname]);

  // Keep sidebar open/closed state in sync when window resizes
  useEffect(() => {
    const onResize = () => {
      if (window.innerWidth >= 769) setSidebarOpen(true);
      else setSidebarOpen(false);
    };
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

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
      localStorage.setItem('driver_sidebar_width', String(newWidth));
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

  const toggle = () => setSidebarOpen((v) => !v);

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  // Derive current page label for topbar title
  const currentPage = NAV_ITEMS.find((n) =>
    location.pathname.startsWith(n.path)
  )?.label ?? 'Dashboard';

  const today = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  const currentWidth = isCollapsed ? 72 : sidebarWidth;

  return (
    <div className={`dl-layout ${sidebarOpen ? 'dl-layout--sidebar-open' : 'dl-layout--sidebar-closed'}`}>

      {/* ── Sidebar ─────────────────────────────────────────── */}
      <aside
        className={`dl-sidebar no-scrollbar admin-sidebar-nav ${sidebarOpen ? 'dl-sidebar--open' : ''}`}
        aria-label="Driver navigation sidebar"
        style={{
          width: window.innerWidth >= 769 ? `${currentWidth}px` : undefined,
          transition: isResizing ? 'none' : 'width 0.2s ease',
          userSelect: isResizing ? 'none' : 'auto',
          position: 'relative',
        }}
      >
        {/* Drag-to-Resize Right Edge Handle */}
        {!isCollapsed && window.innerWidth >= 769 && (
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

        {/* Sidebar header: close button + brand + collapse toggle */}
        <div className="dl-brand" style={{ display: 'flex', alignItems: 'center', justifyContent: isCollapsed ? 'center' : 'space-between' }}>
          <button
            id="dl-close-sidebar-btn"
            type="button"
            className="dl-sidebar-close"
            aria-label="Close sidebar"
            onClick={toggle}
          >
            ✕
          </button>

          {!isCollapsed && (
            <div>
              <Link to="/driver/dashboard" className="dl-brand-link">
                <span className="dl-brand-icon">🚛</span>
                <span className="dl-brand-habesha">Habesha</span>
                <span className="dl-brand-freight">Freight</span>
              </Link>
              <p className="dl-brand-sub">Driver Account</p>
            </div>
          )}

          {/* Desktop Collapse / Expand Button */}
          {window.innerWidth >= 769 && (
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
          )}
        </div>

        {/* Nav */}
        <nav className="dl-nav no-scrollbar" aria-label="Driver navigation" style={{ overflowY: 'auto', msOverflowStyle: 'none', scrollbarWidth: 'none' }}>
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/driver/dashboard' || item.path === '/driver/requests'}
              title={isCollapsed ? item.label : undefined}
              className={({ isActive }) =>
                `dl-nav-item ${isActive ? 'dl-nav-item--active' : ''}`
              }
              style={{
                justifyContent: isCollapsed ? 'center' : 'flex-start',
                whiteSpace: 'nowrap',
              }}
            >
              <span className="dl-nav-icon">{item.icon}</span>
              {!isCollapsed && <span className="dl-nav-label">{item.label}</span>}
            </NavLink>
          ))}
          
          <div style={{ height: '1px', backgroundColor: 'rgba(255,255,255,0.08)', margin: '0.5rem 0' }} />

          <Link to="/" className="dl-nav-item" style={{ justifyContent: isCollapsed ? 'center' : 'flex-start' }} title={isCollapsed ? 'Main Landing Page' : undefined}>
            <span className="dl-nav-icon">🌐</span>
            {!isCollapsed && <span className="dl-nav-label">Main Landing Page</span>}
          </Link>
        </nav>

        {/* User footer */}
        <div className="dl-footer">
          <div className="dl-user-row" style={{ justifyContent: isCollapsed ? 'center' : 'flex-start' }}>
            <div className="dl-user-avatar" aria-hidden="true" title={user?.full_name ?? 'Abebe Girma'}>
              {initials}
            </div>
            {!isCollapsed && (
              <div className="dl-user-info">
                <p className="dl-user-name">{user?.full_name ?? 'Abebe Girma'}</p>
                <p className="dl-user-meta">
                  <span className="dl-star-icon">⭐</span>
                  4.8 · <span className="dl-verified">Verified Driver</span>
                </p>
              </div>
            )}
          </div>

          {!isCollapsed && (
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '0.75rem' }}>
              <button
                id="dl-logout-btn"
                className="dl-logout-btn"
                type="button"
                onClick={handleLogout}
              >
                ← Log Out
              </button>
            </div>
          )}
        </div>
      </aside>

      {/* ── Backdrop (mobile only) ───────────────────────────── */}
      {sidebarOpen && (
        <button
          type="button"
          className="dl-backdrop"
          aria-label="Close menu"
          onClick={toggle}
        />
      )}

      {/* ── Main area ───────────────────────────────────────── */}
      <div
        className="dl-main"
        style={{
          marginLeft: window.innerWidth >= 769 ? `${currentWidth}px` : undefined,
          transition: isResizing ? 'none' : 'margin-left 0.2s ease',
        }}
      >

        {/* Top bar — always visible, hamburger always present */}
        <header className="dl-topbar">
          <button
            id="dl-hamburger-btn"
            type="button"
            className={`dl-hamburger ${sidebarOpen ? 'dl-hamburger--open' : ''}`}
            aria-label={sidebarOpen ? 'Close sidebar' : 'Open sidebar'}
            aria-expanded={sidebarOpen}
            onClick={toggle}
          >
            {/* Three-bar hamburger → X animation */}
            <span className="dl-hamburger-bar" />
            <span className="dl-hamburger-bar" />
            <span className="dl-hamburger-bar" />
          </button>

          <div className="dl-topbar-left">
            <h1 className="dl-topbar-title">{currentPage}</h1>
            <span className="dl-topbar-date">{today}</span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginLeft: 'auto' }}>
            <button
              onClick={() => toggleTheme()}
              style={{
                backgroundColor: '#1E293B',
                color: '#FFFFFF',
                border: 'none',
                borderRadius: '2rem',
                padding: '0.4rem 0.9rem',
                fontSize: '0.825rem',
                fontWeight: 700,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '0.4rem',
              }}
              title="Toggle Light/Dark Theme"
            >
              <span>🌙 / ☀️</span>
              <span>Theme</span>
            </button>
            <Link to="/" style={{ fontSize: '0.85rem', color: '#c8933a', textDecoration: 'none', fontWeight: 500 }}>
              Landing Page 🌐
            </Link>
            <Link to="/driver/dashboard" className="dl-topbar-brand">
              <span>Habesha</span>
              <span className="dl-brand-freight">Freight</span>
            </Link>
          </div>
        </header>

        <main className="dl-content">
          {children}
        </main>
      </div>

    </div>
  );
}

import { ReactNode, useState, useEffect } from 'react';
import { Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import { clearSession, getStoredUser } from '../services/authService';
import '../styles/driver-layout.css'; // reuse identical sidebar styles

interface CompanyLayoutProps {
  children: ReactNode;
}

const NAV_ITEMS = [
  { path: '/company/dashboard',       icon: '🏠', label: 'Dashboard'       },
  { path: '/company/fleet-requests',  icon: '📋', label: 'Fleet Requests'  },
  { path: '/company/deliveries',      icon: '🚚', label: 'Deliveries'      },
  { path: '/company/vehicles',        icon: '🚛', label: 'Vehicles / Fleet'},
  { path: '/company/drivers',         icon: '👤', label: 'Drivers'         },
  { path: '/company/company-profile', icon: '🏢', label: 'Company Profile' },
  { path: '/company/ratings',         icon: '⭐', label: 'Ratings'         },
  { path: '/company/settings',        icon: '⚙️', label: 'Settings'        },
];

export default function CompanyLayout({ children }: CompanyLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(() => window.innerWidth >= 769);

  const navigate = useNavigate();
  const location = useLocation();
  const user     = getStoredUser();

  const initials = (user?.full_name ?? 'ET')
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  // Close sidebar on mobile when route changes
  useEffect(() => {
    if (window.innerWidth < 769) setSidebarOpen(false);
  }, [location.pathname]);

  // Sync sidebar state on resize
  useEffect(() => {
    const onResize = () => {
      if (window.innerWidth >= 769) setSidebarOpen(true);
      else setSidebarOpen(false);
    };
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  const toggle = () => setSidebarOpen((v) => !v);

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  const currentPage =
    NAV_ITEMS.find((n) => location.pathname.startsWith(n.path))?.label ??
    'Dashboard';

  const today = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  return (
    <div className={`dl-layout ${sidebarOpen ? 'dl-layout--sidebar-open' : 'dl-layout--sidebar-closed'}`}>

      {/* ── Sidebar ── */}
      <aside
        className={`dl-sidebar ${sidebarOpen ? 'dl-sidebar--open' : ''}`}
        aria-label="Company navigation sidebar"
      >
        {/* Brand header */}
        <div className="dl-brand">
          <button
            id="co-close-sidebar-btn"
            type="button"
            className="dl-sidebar-close"
            aria-label="Close sidebar"
            onClick={toggle}
          >
            ✕
          </button>
          <Link to="/company/dashboard" className="dl-brand-link">
            <span className="dl-brand-icon">🚛</span>
            <span className="dl-brand-habesha">Habesha</span>
            <span className="dl-brand-freight">Freight</span>
          </Link>
          <p className="dl-brand-sub">Transport Company</p>
        </div>

        {/* Nav */}
        <nav className="dl-nav" aria-label="Company navigation">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/company/dashboard'}
              className={({ isActive }) =>
                `dl-nav-item ${isActive ? 'dl-nav-item--active' : ''}`
              }
            >
              <span className="dl-nav-icon">{item.icon}</span>
              <span className="dl-nav-label">{item.label}</span>
            </NavLink>
          ))}
        </nav>

        {/* User footer */}
        <div className="dl-footer">
          <div className="dl-user-row">
            <div className="dl-user-avatar" aria-hidden="true">
              {initials}
            </div>
            <div className="dl-user-info">
              <p className="dl-user-name">{user?.full_name ?? 'Ethio Transport'}</p>
              <p className="dl-user-meta">Transport Co.</p>
            </div>
          </div>

          <button
            id="co-logout-btn"
            className="dl-logout-btn"
            type="button"
            onClick={handleLogout}
          >
            ← Log Out
          </button>
        </div>
      </aside>

      {/* ── Mobile backdrop ── */}
      {sidebarOpen && (
        <button
          type="button"
          className="dl-backdrop"
          aria-label="Close menu"
          onClick={toggle}
        />
      )}

      {/* ── Main area ── */}
      <div className="dl-main">
        <header className="dl-topbar">
          <button
            id="co-hamburger-btn"
            type="button"
            className={`dl-hamburger ${sidebarOpen ? 'dl-hamburger--open' : ''}`}
            aria-label={sidebarOpen ? 'Close sidebar' : 'Open sidebar'}
            aria-expanded={sidebarOpen}
            onClick={toggle}
          >
            <span className="dl-hamburger-bar" />
            <span className="dl-hamburger-bar" />
            <span className="dl-hamburger-bar" />
          </button>

          <div className="dl-topbar-left">
            <h1 className="dl-topbar-title">{currentPage}</h1>
            <span className="dl-topbar-date">{today}</span>
          </div>

          <Link to="/company/dashboard" className="dl-topbar-brand">
            <span>Habesha</span>
            <span className="dl-brand-freight">Freight</span>
          </Link>
        </header>

        <main className="dl-content">
          {children}
        </main>
      </div>

    </div>
  );
}

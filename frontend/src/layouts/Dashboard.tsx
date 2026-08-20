import { ReactNode, useState } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import type { NavItem, Person2Role } from '../types/person2';
import { clearSession, getStoredUser } from '../services/authService';

interface Person2LayoutProps {
  role: Person2Role;
  navItems: NavItem[];
  children: ReactNode;
}

const roleLabels: Record<Person2Role, string> = {
  driver: 'Driver Portal',
  company: 'Company Portal',
  admin: 'Admin Console',
  shipper: 'Shipper Dashboard',
};

export default function Person2Layout({ role, navItems, children }: Person2LayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const navigate = useNavigate();
  const user = getStoredUser();

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  return (
    <div className="p2-layout">
      <aside className={`p2-sidebar ${sidebarOpen ? 'p2-sidebar--open' : ''}`}>
        <div className="p2-sidebar-brand">
          <Link to={role === 'shipper' ? '/dashboard' : `/${role}`} className="p2-brand-link">
            <span className="p2-brand-habesha">Habesha</span>
            <span className="p2-brand-freight">Freight</span>
          </Link>
          <span className="p2-role-badge">{roleLabels[role]}</span>
        </div>

        <nav className="p2-nav">
          {navItems.map((item) => (
            <div key={item.path} className="p2-nav-group">
              <NavLink
                to={item.path}
                end={item.path === `/${role}`}
                className={({ isActive }) =>
                  `p2-nav-link ${isActive ? 'p2-nav-link--active' : ''}`
                }
                onClick={() => setSidebarOpen(false)}
              >
                {item.icon && <span className="p2-nav-icon">{item.icon}</span>}
                {item.label}
              </NavLink>
              {item.children?.map((child) => (
                <NavLink
                  key={child.path}
                  to={child.path}
                  className={({ isActive }) =>
                    `p2-nav-sublink ${isActive ? 'p2-nav-link--active' : ''}`
                  }
                  onClick={() => setSidebarOpen(false)}
                >
                  {child.label}
                </NavLink>
              ))}
            </div>
          ))}
        </nav>

        <div className="p2-sidebar-footer">
          <div className="p2-user-chip">
            <div className="p2-user-avatar">
              {(user?.full_name ?? 'U').charAt(0).toUpperCase()}
            </div>
            <div>
              <div className="p2-user-name">{user?.full_name ?? 'User'}</div>
              <div className="p2-user-role">{user?.role ?? ''}</div>
            </div>
          </div>
          <button type="button" className="p2-logout-btn" onClick={handleLogout}>
            Log out
          </button>
        </div>
      </aside>

      <div className="p2-main">
        <header className="p2-topbar">
          <button
            type="button"
            className="p2-menu-toggle"
            onClick={() => setSidebarOpen(!sidebarOpen)}
            aria-label="Toggle menu"
          >
            ☰
          </button>
          <span className="p2-topbar-title">{roleLabels[role]}</span>
        </header>
        <div className="p2-content">{children}</div>
      </div>

      {sidebarOpen && (
        <button
          type="button"
          className="p2-sidebar-overlay"
          aria-label="Close menu"
          onClick={() => setSidebarOpen(false)}
        />
      )}
    </div>
  );
}

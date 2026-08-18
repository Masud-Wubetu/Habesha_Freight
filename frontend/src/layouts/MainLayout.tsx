import { ReactNode, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useTheme } from '../context/ThemeContext';

interface MainLayoutProps {
  children: ReactNode;
}

export default function MainLayout({ children }: MainLayoutProps) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const location = useLocation();
  const isDashboard = location.pathname === '/dashboard';
  const { theme, toggleTheme } = useTheme();

  if (isDashboard) {
    return <div>{children}</div>;
  }

  return (
    <div className={`main-layout ${theme}`}>
      <header className="navbar" style={{ 
        backgroundColor: theme === 'dark' ? '#070F19' : '#0B1F33',
        height: '64px',
        position: 'sticky',
        top: 0,
        zIndex: 1000,
        borderBottom: '1px solid rgba(255,255,255,0.05)'
      }}>
        <div className="container" style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center', 
          height: '100%',
          padding: '0 1.5rem'
        }}>
          <Link to="/" className="navbar-logo" style={{ 
            fontSize: '1.25rem', 
            fontWeight: '700',
            fontFamily: 'DM Sans, sans-serif',
            display: 'flex',
            alignItems: 'center',
            gap: '0.25rem',
            flexShrink: 0
          }}>
            <span style={{ fontSize: '1.25rem' }}>🚚</span>
            <span style={{ color: '#FFFFFF' }}>Habesha</span>
            <span style={{ color: '#C8933A' }}>Freight</span>
          </Link>

          <nav className="desktop-nav" style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '1.5rem'
          }}>
            <div style={{ display: 'flex', gap: '1.5rem' }}>
              <a href="/#how-it-works" className="btn-nav">How It Works</a>
              <a href="/#features" className="btn-nav">Features</a>
              <a href="/#routes" className="btn-nav">Routes</a>
            </div>
            
            <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
              <button
                onClick={toggleTheme}
                className="btn-nav"
                style={{ fontSize: '1.2rem', padding: '0.25rem 0.5rem' }}
                aria-label="Toggle theme"
              >
                {theme === 'dark' ? '☀️' : '🌙'}
              </button>
              <Link to="/login" className="btn-nav">Log In</Link>
              <Link to="/register" className="btn-register" style={{
                display: 'inline-block',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                padding: '0.5rem 1.5rem',
                borderRadius: '0.5rem',
                fontWeight: '500',
                fontFamily: 'DM Sans, sans-serif',
                transition: 'background-color 0.2s',
                textDecoration: 'none'
              }}
              onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#F0B84A'}
              onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#C8933A'}
              >
                Register
              </Link>
            </div>
          </nav>

          <div style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '0.5rem'
          }}>
            <button
              onClick={toggleTheme}
              className="btn-nav"
              style={{ 
                fontSize: '1.2rem', 
                padding: '0.25rem 0.5rem',
                background: 'none',
                border: 'none',
                color: '#FFFFFF',
                cursor: 'pointer'
              }}
              aria-label="Toggle theme"
            >
              {theme === 'dark' ? '☀️' : '🌙'}
            </button>
            
            <button
              className="mobile-menu-btn"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              style={{
                background: 'none',
                border: 'none',
                color: '#FFFFFF',
                fontSize: '1.5rem',
                cursor: 'pointer',
                padding: '0.25rem 0.5rem',
                display: 'block'
              }}
            >
              ☰
            </button>
          </div>
        </div>

        {isMobileMenuOpen && (
          <div style={{
            backgroundColor: theme === 'dark' ? '#070F19' : '#0B1F33',
            padding: '1rem 1.5rem',
            borderTop: '1px solid rgba(255,255,255,0.05)',
            display: 'flex',
            flexDirection: 'column',
            gap: '0.75rem'
          }}>
            <a 
              href="/#how-it-works" 
              className="btn-nav" 
              onClick={() => setIsMobileMenuOpen(false)}
              style={{ color: '#FFFFFF', textDecoration: 'none', padding: '0.5rem 0' }}
            >
              How It Works
            </a>
            <a 
              href="/#features" 
              className="btn-nav" 
              onClick={() => setIsMobileMenuOpen(false)}
              style={{ color: '#FFFFFF', textDecoration: 'none', padding: '0.5rem 0' }}
            >
              Features
            </a>
            <Link 
              to="/login" 
              className="btn-nav" 
              onClick={() => setIsMobileMenuOpen(false)}
              style={{ color: '#FFFFFF', textDecoration: 'none', padding: '0.5rem 0' }}
            >
              Log In
            </Link>
            <Link 
              to="/register" 
              onClick={() => setIsMobileMenuOpen(false)}
              style={{
                display: 'inline-block',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                padding: '0.5rem 1.5rem',
                borderRadius: '0.5rem',
                fontWeight: '500',
                fontFamily: 'DM Sans, sans-serif',
                textAlign: 'center',
                textDecoration: 'none',
                alignSelf: 'flex-start',
                marginTop: '0.25rem'
              }}
            >
              Register
            </Link>
          </div>
        )}
      </header>

      <main>{children}</main>
    </div>
  );
}
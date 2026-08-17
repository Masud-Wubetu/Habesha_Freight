import { ReactNode, useState } from 'react';
import { Link } from 'react-router-dom';
import { getStoredUser } from '../services/authService';

interface MainLayoutProps {
  children: ReactNode;
}

export default function MainLayout({ children }: MainLayoutProps) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const user = getStoredUser();

  return (
    <div>
      {/* Navbar */}
      <header className="navbar" style={{ 
        backgroundColor: '#0B1F33', 
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
          padding: '0 2rem'
        }}>
          {/* Logo */}
          <Link to="/" className="navbar-logo" style={{ 
            fontSize: '1.5rem', 
            fontWeight: '700',
            fontFamily: 'DM Sans, sans-serif',
            display: 'flex',
            alignItems: 'center',
            gap: '0.25rem'
          }}>
            <span style={{ color: '#FFFFFF' }}>Habesha</span>
            <span style={{ color: '#C8933A' }}>Freight</span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="desktop-nav" style={{ 
            display: 'flex', 
            alignItems: 'center', 
            gap: '1.5rem'
          }}>
            <div style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
              <a href="/#search" className="btn-nav">Find Trucks</a>
              <a href="/#how-it-works" className="btn-nav">How It Works</a>
              <Link to="/driver/dashboard" className="btn-nav" style={{ color: '#C8933A', fontWeight: 600 }}>
                🚛 Driver Portal
              </Link>
            </div>
            
            <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
              {user ? (
                <Link to={user.role === 'DRIVER' ? '/driver/dashboard' : '/dashboard'} style={{
                  display: 'inline-block',
                  backgroundColor: '#C8933A',
                  color: '#FFFFFF',
                  padding: '0.5rem 1.25rem',
                  borderRadius: '0.5rem',
                  fontWeight: '500',
                  fontFamily: 'DM Sans, sans-serif',
                  textDecoration: 'none'
                }}>
                  Dashboard ({user.full_name.split(' ')[0]})
                </Link>
              ) : (
                <>
                  <Link to="/login" className="btn-nav">Log In</Link>
                  <Link to="/register" style={{
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
                </>
              )}
            </div>
          </nav>

          {/* Mobile Menu Button */}
          <button
            className="mobile-menu-btn"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            style={{
              display: 'none',
              background: 'none',
              border: 'none',
              color: '#FFFFFF',
              fontSize: '1.5rem',
              cursor: 'pointer'
            }}
          >
            ☰
          </button>
        </div>

        {/* Mobile Menu */}
        {isMobileMenuOpen && (
          <div style={{
            backgroundColor: '#0B1F33',
            padding: '1rem 2rem',
            borderTop: '1px solid rgba(255,255,255,0.05)'
          }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              <a href="/#search" className="btn-nav" onClick={() => setIsMobileMenuOpen(false)}>Find Trucks</a>
              <a href="/#how-it-works" className="btn-nav" onClick={() => setIsMobileMenuOpen(false)}>How It Works</a>
              <Link to="/driver/dashboard" className="btn-nav" style={{ color: '#C8933A', fontWeight: 600 }} onClick={() => setIsMobileMenuOpen(false)}>
                🚛 Driver Portal
              </Link>
              {user ? (
                <Link to={user.role === 'DRIVER' ? '/driver/dashboard' : '/dashboard'} className="btn-nav" onClick={() => setIsMobileMenuOpen(false)}>
                  My Dashboard
                </Link>
              ) : (
                <>
                  <Link to="/login" className="btn-nav" onClick={() => setIsMobileMenuOpen(false)}>Log In</Link>
                  <Link to="/register" style={{
                    display: 'inline-block',
                    backgroundColor: '#C8933A',
                    color: '#FFFFFF',
                    padding: '0.5rem 1.5rem',
                    borderRadius: '0.5rem',
                    fontWeight: '500',
                    fontFamily: 'DM Sans, sans-serif',
                    textAlign: 'center',
                    textDecoration: 'none'
                  }}
                  onClick={() => setIsMobileMenuOpen(false)}
                  >
                    Register
                  </Link>
                </>
              )}
            </div>
          </div>
        )}
      </header>

      {/* Main Content */}
      <main>{children}</main>
    </div>
  );
}
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

export default function Login() {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [faydaNumber, setFaydaNumber] = useState('');
  const [faydaVerified, setFaydaVerified] = useState(false);
  const [isVerifyingFayda, setIsVerifyingFayda] = useState(false);
  const [faydaError, setFaydaError] = useState('');
  const [selectedRole, setSelectedRole] = useState('Main Admin');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  const { login } = useAuth();
  const navigate = useNavigate();

  const roles = [
    { id: 'shipper', label: 'Shipper', icon: '📦' },
    { id: 'driver', label: 'Driver', icon: '🚚' },
    { id: 'transport', label: 'Transport Company', icon: '🏢' },
    { id: 'admin', label: 'Main Admin', icon: '⚙️' },
  ];

  const handleVerifyFayda = () => {
    if (!faydaNumber.trim()) {
      setFaydaError('Please enter your Fayda number');
      return;
    }

    setIsVerifyingFayda(true);
    setFaydaError('');

    setTimeout(() => {
      if (faydaNumber.length >= 10) {
        setFaydaVerified(true);
        setFaydaError('');
      } else {
        setFaydaError('Invalid Fayda number');
        setFaydaVerified(false);
      }
      setIsVerifyingFayda(false);
    }, 1500);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!phoneNumber.trim()) {
      setError('Phone number is required');
      return;
    }
    if (!password.trim()) {
      setError('Password is required');
      return;
    }

    setIsLoading(true);

    try {
      await login(phoneNumber, password);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Login failed. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page">
      {/* Top Header */}
      <header className="login-header">
        <div className="login-header-content">
          <Link to="/" className="login-back">
            ← Back
          </Link>
          <div className="login-brand">
            <span className="brand-icon">🚚</span>
            <span className="brand-habesha">Habesha</span>
            <span className="brand-freight">Freight</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="login-page-content">
        <div className="login-card">
          {/* Login/Register Switch */}
          <div className="auth-switch">
            <button className="auth-tab active">Log In</button>
            <Link to="/register" className="auth-tab">Register</Link>
          </div>

          {/* Welcome Section */}
          <h1 className="login-welcome">Welcome back</h1>
          <p className="login-subtitle">Log in to your HabeshaFreight account.</p>

          {error && (
            <div className="login-error">{error}</div>
          )}

          <form onSubmit={handleSubmit}>
            {/* Phone or Email */}
            <div className="form-group">
              <label>Phone or Email</label>
              <input
                type="tel"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
                placeholder="+251 912 345 678"
                disabled={isLoading}
                className="form-input"
              />
            </div>

            {/* Password */}
            <div className="form-group">
              <label>Password</label>
              <div className="password-wrapper">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  disabled={isLoading}
                  className="form-input"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="password-toggle"
                  disabled={isLoading}
                >
                  {showPassword ? 'Hide' : 'Show'}
                </button>
              </div>
            </div>

            {/* Fayda Section */}
            <div className="fayda-section">
              <div className="fayda-header">
                <span className="fayda-label">
                  🪪 Fayda Number <span className="fayda-optional">(optional)</span>
                </span>
                {faydaVerified && (
                  <span className="fayda-verified">✓ Fayda Verified</span>
                )}
              </div>
              
              <div className="fayda-row">
                <input
                  type="text"
                  value={faydaNumber}
                  onChange={(e) => {
                    setFaydaNumber(e.target.value);
                    setFaydaVerified(false);
                    setFaydaError('');
                  }}
                  placeholder="Enter your Fayda number"
                  disabled={isLoading || isVerifyingFayda || faydaVerified}
                  className={`fayda-input ${faydaVerified ? 'fayda-input-verified' : ''}`}
                />
                <button
                  type="button"
                  onClick={handleVerifyFayda}
                  disabled={isLoading || isVerifyingFayda || faydaVerified || !faydaNumber.trim()}
                  className="fayda-verify-btn"
                >
                  {isVerifyingFayda ? 'Verifying...' : faydaVerified ? '✓ Verified' : 'Verify'}
                </button>
              </div>
              
              {faydaError && (
                <div className="fayda-error">{faydaError}</div>
              )}
            </div>

            {/* Role Selector */}
            <div className="role-section">
              <label className="role-label">Log in as</label>
              <div className="role-grid">
                {roles.map((role) => (
                  <button
                    key={role.id}
                    type="button"
                    onClick={() => setSelectedRole(role.label)}
                    className={`role-card ${selectedRole === role.label ? 'active' : ''}`}
                  >
                    <span className="role-icon">{role.icon}</span>
                    <span className="role-name">{role.label}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Login Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="login-btn-primary"
            >
              {isLoading ? 'Logging in...' : 'Log In →'}
            </button>
          </form>

          {/* Forgot Password */}
          <div className="login-forgot">
            Forgot password?
          </div>

          {/* Register Prompt */}
          <div className="login-register-prompt">
            Don't have an account? <Link to="/register" className="register-link">Register</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
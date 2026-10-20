import { useState, useEffect, FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const LAST_LOGIN_ID_KEY = 'hf_last_login_id';

export default function Login() {
  const [identifier, setIdentifier] = useState(() => {
    try {
      return localStorage.getItem(LAST_LOGIN_ID_KEY) ?? '';
    } catch {
      return '';
    }
  });
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  // Helps Chrome autofill on controlled React inputs (unlock after first paint)
  const [autofillUnlocked, setAutofillUnlocked] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const unlock = window.setTimeout(() => setAutofillUnlocked(true), 50);
    // Capture browser autofill that may not fire onChange
    const syncAutofill = () => {
      const userEl = document.getElementById('login-username') as HTMLInputElement | null;
      const passEl = document.getElementById('login-password') as HTMLInputElement | null;
      if (userEl?.value) setIdentifier((prev) => (prev === userEl.value ? prev : userEl.value));
      if (passEl?.value) setPassword((prev) => (prev === passEl.value ? prev : passEl.value));
    };
    const t1 = window.setTimeout(syncAutofill, 100);
    const t2 = window.setTimeout(syncAutofill, 600);
    window.addEventListener('focus', syncAutofill);
    return () => {
      window.clearTimeout(unlock);
      window.clearTimeout(t1);
      window.clearTimeout(t2);
      window.removeEventListener('focus', syncAutofill);
    };
  }, []);

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');

    // Prefer FormData so browser-autofilled values are always included
    const fd = new FormData(e.currentTarget);
    const idValue = String(fd.get('username') || identifier).trim();
    const passwordValue = String(fd.get('password') || password);

    if (!idValue) {
      setError('Email address or phone number is required');
      return;
    }
    if (!passwordValue.trim()) {
      setError('Password is required');
      return;
    }

    setIdentifier(idValue);
    setPassword(passwordValue);
    setIsLoading(true);

    try {
      const user = await login(idValue, passwordValue);

      try {
        localStorage.setItem(LAST_LOGIN_ID_KEY, idValue);
      } catch {
        /* ignore quota */
      }

      const isPendingRole = user.role === 'DRIVER' || user.role === 'FLEET_OWNER';
      const isPendingStatus = user.kyc_status === 'PENDING' || user.status === 'PENDING_APPROVAL';

      if (isPendingRole && isPendingStatus) {
        navigate('/pending-approval');
      } else {
        const roleHome: Record<string, string> = {
          DRIVER: '/driver',
          FLEET_OWNER: '/company',
          ADMIN: '/admin',
          SHIPPER: '/dashboard',
        };
        navigate(roleHome[user.role] ?? '/');
      }
    } catch (err: any) {
      if (err.requires_otp_verification) {
        localStorage.setItem('registrationEmail', err.email || idValue);
        navigate('/verify-otp');
        return;
      }
      setError(err.message || 'Login failed. Please check your credentials and try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page">
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

      <div className="login-page-content">
        <div className="login-card">
          <div className="auth-switch">
            <button type="button" className="auth-tab active">
              Log In
            </button>
            <Link to="/register" className="auth-tab">
              Register
            </Link>
          </div>

          <h1 className="login-welcome">Welcome back</h1>
          <p className="login-subtitle">Log in to your HabeshaFreight account.</p>

          {error && (
            <div className="login-error" role="alert">
              {error}
            </div>
          )}

          <form
            method="post"
            action="/login"
            autoComplete="on"
            onSubmit={handleSubmit}
            noValidate
          >
            <div className="form-group">
              <label htmlFor="login-username">Email Address or Phone Number</label>
              <input
                id="login-username"
                name="username"
                type="text"
                inputMode="email"
                autoComplete="username"
                autoCapitalize="none"
                autoCorrect="off"
                spellCheck={false}
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                onInput={(e) => setIdentifier((e.target as HTMLInputElement).value)}
                placeholder="dawit@example.com or +251..."
                disabled={isLoading}
                className="form-input"
                readOnly={!autofillUnlocked}
                onFocus={() => setAutofillUnlocked(true)}
                required
              />
            </div>

            <div className="form-group">
              <label htmlFor="login-password">Password</label>
              <div className="password-wrapper">
                <input
                  id="login-password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  onInput={(e) => setPassword((e.target as HTMLInputElement).value)}
                  placeholder="Enter your password"
                  disabled={isLoading}
                  className="form-input"
                  readOnly={!autofillUnlocked}
                  onFocus={() => setAutofillUnlocked(true)}
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="password-toggle"
                  disabled={isLoading}
                  tabIndex={-1}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? 'Hide' : 'Show'}
                </button>
              </div>
            </div>

            <button type="submit" disabled={isLoading} className="login-btn-primary">
              {isLoading ? 'Logging in...' : 'Log In →'}
            </button>
          </form>

          <div className="login-register-prompt">
            Don't have an account?{' '}
            <Link to="/register" className="register-link">
              Register
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

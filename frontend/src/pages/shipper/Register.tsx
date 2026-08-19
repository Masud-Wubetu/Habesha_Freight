import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

type Role = 'shipper' | 'driver' | 'transport' | 'admin';

interface RoleOption {
  id: Role;
  icon: string;
  title: string;
  subtitle: string;
}

export default function Register() {
  const navigate = useNavigate();
  const [step, setStep] = useState<'role' | 'details' | 'fayda'>('role');
  const [selectedRole, setSelectedRole] = useState<Role>('shipper');
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    phoneNumber: '',
    email: '',
    password: '',
  });
  const [faydaNumber, setFaydaNumber] = useState('');
  const [faydaVerified, setFaydaVerified] = useState(false);
  const [isVerifying, setIsVerifying] = useState(false);
  const [faydaError, setFaydaError] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const roles: RoleOption[] = [
    {
      id: 'shipper',
      icon: '📦',
      title: 'I need a truck',
      subtitle: 'Shipper',
    },
    {
      id: 'driver',
      icon: '🚚',
      title: 'I drive a truck',
      subtitle: 'Driver',
    },
    {
      id: 'transport',
      icon: '🏢',
      title: 'I manage a fleet',
      subtitle: 'Transport Company',
    },
    {
      id: 'admin',
      icon: '⚙️',
      title: 'I administer the platform',
      subtitle: 'Main Admin',
    },
  ];

  const roleLabels: Record<Role, string> = {
    shipper: 'Shipper',
    driver: 'Driver',
    transport: 'Transport Company',
    admin: 'Main Admin',
  };

  const handleContinue = () => {
    setStep('details');
  };

  const handleBack = () => {
    if (step === 'details') {
      setStep('role');
    } else if (step === 'fayda') {
      setStep('details');
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  const validateDetails = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.firstName.trim()) {
      newErrors.firstName = 'First name is required';
    }
    if (!formData.lastName.trim()) {
      newErrors.lastName = 'Last name is required';
    }
    if (!formData.phoneNumber.trim()) {
      newErrors.phoneNumber = 'Phone number is required';
    }
    if (!formData.password.trim()) {
      newErrors.password = 'Password is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateDetails()) {
      setStep('fayda');
    }
  };

  const handleVerifyFayda = () => {
    if (!faydaNumber.trim()) {
      setFaydaError('Please enter your Fayda number');
      return;
    }

    setIsVerifying(true);
    setFaydaError('');

    setTimeout(() => {
      if (faydaNumber.length >= 10) {
        setFaydaVerified(true);
        setFaydaError('');
      } else {
        setFaydaError('Invalid Fayda number. Please check and try again.');
        setFaydaVerified(false);
      }
      setIsVerifying(false);
    }, 1500);
  };

  const handleFaydaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFaydaNumber(e.target.value);
    setFaydaVerified(false);
    setFaydaError('');
  };

  const handleVerifyToContinue = () => {
    if (faydaVerified) {
      // Store registration data in localStorage or state for OTP page
      const fullName = `${formData.firstName} ${formData.lastName}`;
      const phoneNumber = `+251${formData.phoneNumber.replace(/\s/g, '')}`;
      
      const registrationData = {
        full_name: fullName,
        phone_number: phoneNumber,
        email: formData.email || undefined,
        password: formData.password,
        role: selectedRole,
        fayda_number: faydaNumber,
      };

      localStorage.setItem('registrationData', JSON.stringify(registrationData));
      navigate('/verify-otp');
    }
  };

  return (
    <div className="register-page">
      <header className="register-header">
        <div className="register-header-content">
          <Link to="/" className="register-back">
            ← Back
          </Link>
          <div className="register-brand">
            <span className="brand-icon">🚚</span>
            <span className="brand-habesha">Habesha</span>
            <span className="brand-freight">Freight</span>
          </div>
        </div>
      </header>

      <div className="register-page-content">
        <div className="register-card">
          <div className="register-switch">
            <Link to="/login" className="register-tab">Log In</Link>
            <button className="register-tab active">Register</button>
          </div>

          {step === 'role' && (
            <>
              <h1 className="register-welcome">Who are you?</h1>
              <p className="register-subtitle">Choose your role on HabeshaFreight.</p>

              <div className="role-list">
                {roles.map((role) => (
                  <button
                    key={role.id}
                    onClick={() => setSelectedRole(role.id)}
                    className={`role-item ${selectedRole === role.id ? 'selected' : ''}`}
                  >
                    <div className="role-item-left">
                      <span className="role-item-icon">{role.icon}</span>
                      <div className="role-item-text">
                        <span className="role-item-title">{role.title}</span>
                        <span className="role-item-subtitle">{role.subtitle}</span>
                      </div>
                    </div>
                    {selectedRole === role.id && (
                      <span className="role-item-check">✓</span>
                    )}
                  </button>
                ))}
              </div>

              <button
                onClick={handleContinue}
                className="register-continue-btn"
              >
                Continue →
              </button>

              <div className="register-login-prompt">
                Already have an account? <Link to="/login" className="register-login-link">Log In</Link>
              </div>
            </>
          )}

          {step === 'details' && (
            <>
              <h1 className="register-welcome">Create Account</h1>
              <p className="register-subtitle">
                Registering as {roleLabels[selectedRole]}
              </p>

              <form onSubmit={(e) => e.preventDefault()} className="register-details-form">
                <div className="form-row">
                  <div className="form-group">
                    <label>First Name</label>
                    <input
                      type="text"
                      name="firstName"
                      value={formData.firstName}
                      onChange={handleInputChange}
                      placeholder="Dawit"
                      className={`form-input ${errors.firstName ? 'input-error' : ''}`}
                    />
                    {errors.firstName && (
                      <span className="input-error-text">{errors.firstName}</span>
                    )}
                  </div>

                  <div className="form-group">
                    <label>Last Name</label>
                    <input
                      type="text"
                      name="lastName"
                      value={formData.lastName}
                      onChange={handleInputChange}
                      placeholder="Bekele"
                      className={`form-input ${errors.lastName ? 'input-error' : ''}`}
                    />
                    {errors.lastName && (
                      <span className="input-error-text">{errors.lastName}</span>
                    )}
                  </div>
                </div>

                <div className="form-group">
                  <label>Phone Number</label>
                  <div className="phone-input-wrapper">
                    <span className="phone-prefix">🇪🇹 +251</span>
                    <input
                      type="tel"
                      name="phoneNumber"
                      value={formData.phoneNumber}
                      onChange={handleInputChange}
                      placeholder="912 345 678"
                      className={`form-input phone-input ${errors.phoneNumber ? 'input-error' : ''}`}
                    />
                  </div>
                  {errors.phoneNumber && (
                    <span className="input-error-text">{errors.phoneNumber}</span>
                  )}
                </div>

                <div className="form-group">
                  <label>Email <span className="field-optional">(optional)</span></label>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    placeholder="dawit@example.com"
                    className="form-input"
                  />
                </div>

                <div className="form-group">
                  <label>Password</label>
                  <input
                    type="password"
                    name="password"
                    value={formData.password}
                    onChange={handleInputChange}
                    placeholder="Enter your password"
                    className={`form-input ${errors.password ? 'input-error' : ''}`}
                  />
                  {errors.password && (
                    <span className="input-error-text">{errors.password}</span>
                  )}
                </div>

                <div className="register-details-actions">
                  <button
                    type="button"
                    onClick={handleBack}
                    className="register-back-btn"
                  >
                    Back
                  </button>
                  <button
                    type="button"
                    onClick={handleNext}
                    className="register-next-btn"
                  >
                    Next →
                  </button>
                </div>
              </form>
            </>
          )}

          {step === 'fayda' && (
            <>
              <h1 className="register-welcome">🪪 Fayda Verification</h1>
              <p className="register-subtitle">
                Enter your Fayda number to verify your identity.<br />
                This helps us keep HabeshaFreight safe and trusted.
              </p>

              <div className="fayda-verification-section">
                <div className="form-group">
                  <label>Fayda Number</label>
                  <div className="fayda-input-wrapper">
                    <input
                      type="text"
                      value={faydaNumber}
                      onChange={handleFaydaChange}
                      placeholder="e.g. FY-1234-5678-9012"
                      className={`form-input fayda-input-field ${faydaVerified ? 'fayda-input-verified' : ''}`}
                    />
                    <button
                      type="button"
                      onClick={handleVerifyFayda}
                      disabled={isVerifying || faydaVerified || !faydaNumber.trim()}
                      className="fayda-verify-action-btn"
                    >
                      {isVerifying ? 'Verifying...' : 'Verify'}
                    </button>
                  </div>
                  {faydaError && (
                    <span className="input-error-text">{faydaError}</span>
                  )}
                  {faydaVerified && (
                    <span className="fayda-success-text">✓ Fayda Verified</span>
                  )}
                </div>

                <p className="fayda-supporting-text">
                  Your Fayda number can be found on your national ID card.<br />
                  Verification is required to use HabeshaFreight.
                </p>
              </div>

              <div className="register-details-actions">
                <button
                  type="button"
                  onClick={handleBack}
                  className="register-back-btn"
                >
                  Back
                </button>
                <button
                  type="button"
                  onClick={handleVerifyToContinue}
                  disabled={!faydaVerified}
                  className={`register-next-btn ${!faydaVerified ? 'fayda-continue-disabled' : ''}`}
                >
                  Verify to Continue
                </button>
              </div>

              <p className="fayda-footer-text">
                Fayda verification is powered by Ethiopia's national digital ID system.
              </p>

              <div className="register-login-prompt">
                Already have an account? <Link to="/login" className="register-login-link">Log In</Link>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
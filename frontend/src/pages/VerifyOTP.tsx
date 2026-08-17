import { useState, useRef, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';

export default function VerifyOTP() {
  const navigate = useNavigate();
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [otpError, setOtpError] = useState('');
  const [isVerifying, setIsVerifying] = useState(false);
  const [otpVerified, setOtpVerified] = useState(false);
  const [resendTimer, setResendTimer] = useState(30);
  const [canResend, setCanResend] = useState(false);
  const [phoneNumber, setPhoneNumber] = useState('');
  const [faydaVerified, setFaydaVerified] = useState(false);
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    const data = localStorage.getItem('registrationData');
    if (data) {
      const parsed = JSON.parse(data);
      setPhoneNumber(parsed.phone_number || '');
      setFaydaVerified(true);
    }
  }, []);

  useEffect(() => {
    if (resendTimer > 0) {
      const timer = setTimeout(() => {
        setResendTimer(resendTimer - 1);
      }, 1000);
      return () => clearTimeout(timer);
    } else if (resendTimer === 0 && !canResend) {
      setCanResend(true);
    }
  }, [resendTimer, canResend]);

  const handleOtpChange = (index: number, value: string) => {
    if (!/^\d*$/.test(value)) return;

    const newOtp = [...otp];
    newOtp[index] = value.slice(0, 1);
    setOtp(newOtp);
    setOtpError('');

    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handleOtpPaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pasteData = e.clipboardData.getData('text').slice(0, 6);
    if (!/^\d*$/.test(pasteData)) return;

    const digits = pasteData.split('');
    const newOtp = [...otp];
    digits.forEach((digit, idx) => {
      if (idx < 6) newOtp[idx] = digit;
    });
    setOtp(newOtp);

    const nextIndex = Math.min(digits.length, 5);
    inputRefs.current[nextIndex]?.focus();
  };

  const handleVerifyOtp = () => {
    const otpString = otp.join('');
    if (otpString.length < 6) {
      setOtpError('Please enter all 6 digits');
      return;
    }

    setIsVerifying(true);
    setOtpError('');

    setTimeout(() => {
      if (otpString === '123456') {
        setOtpVerified(true);
        setOtpError('');
        console.log('OTP verified successfully!');
        setTimeout(() => {
          navigate('/dashboard');
        }, 500);
      } else {
        setOtpError('Invalid OTP. Please try again.');
        setOtp(['', '', '', '', '', '']);
        inputRefs.current[0]?.focus();
      }
      setIsVerifying(false);
    }, 1500);
  };

  const handleResendOtp = () => {
    if (canResend) {
      setOtp(['', '', '', '', '', '']);
      setOtpError('');
      setResendTimer(30);
      setCanResend(false);
      inputRefs.current[0]?.focus();
    }
  };

  return (
    <div className="register-page">
      <header className="register-header">
        <div className="register-header-content">
          <Link to="/register" className="register-back">
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

          <h1 className="register-welcome">📱 Verify Phone</h1>
          <p className="register-subtitle">
            Enter the 6-digit OTP sent to {phoneNumber}
          </p>

          <div className="otp-demo-badge">
            Demo OTP: <strong>123456</strong>
          </div>

          {faydaVerified && (
            <div className="otp-fayda-badge">
              ✓ Fayda Verified
            </div>
          )}

          <div className="otp-container">
            <div className="otp-inputs">
              {otp.map((digit, index) => (
                <input
                  key={index}
                  ref={(el) => (inputRefs.current[index] = el)}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={(e) => handleOtpChange(index, e.target.value)}
                  onKeyDown={(e) => handleOtpKeyDown(index, e)}
                  onPaste={handleOtpPaste}
                  className={`otp-input ${otpError ? 'otp-input-error' : ''}`}
                  disabled={isVerifying || otpVerified}
                />
              ))}
            </div>
            {otpError && (
              <span className="input-error-text otp-error-text">{otpError}</span>
            )}
          </div>

          <div className="otp-resend">
            <span className="otp-resend-text">
              {resendTimer > 0 ? `Resend OTP in ${resendTimer}s` : "Didn't receive the code?"}
            </span>
            <button
              type="button"
              onClick={handleResendOtp}
              disabled={!canResend}
              className="otp-resend-btn"
            >
              Resend OTP
            </button>
          </div>

          <div className="register-details-actions">
            <button
              type="button"
              onClick={() => navigate('/register')}
              className="register-back-btn"
            >
              Back
            </button>
            <button
              type="button"
              onClick={handleVerifyOtp}
              disabled={otp.join('').length < 6 || isVerifying || otpVerified}
              className={`register-next-btn ${otp.join('').length < 6 ? 'otp-continue-disabled' : ''}`}
            >
              {isVerifying ? 'Verifying...' : 'Verify & Enter →'}
            </button>
          </div>

          <div className="register-login-prompt">
            Already have an account? <Link to="/login" className="register-login-link">Log In</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
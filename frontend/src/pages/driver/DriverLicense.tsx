import { FormEvent, useEffect, useState } from 'react';
import PageHeader from '../../components/PageHeader';
import { get, put } from '../../services/api';

export default function DriverLicense() {
  const [licenseNumber, setLicenseNumber] = useState('');
  const [licenseClass, setLicenseClass] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await get<any>('/drivers/profile');
        const data = res?.data ?? res;
        if (cancelled) return;
        setLicenseNumber(data?.license_number || data?.licenseNumber || '');
        setLicenseClass(data?.license_class || data?.licenseClass || '');
      } catch (e: any) {
        if (!cancelled) setError(e?.message || 'Unable to load driver profile');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleSave = async (e: FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setMessage(null);
    setError(null);
    try {
      await put('/drivers/profile', {
        license_number: licenseNumber.trim(),
        license_class: licenseClass || undefined,
      });
      setMessage('License details saved to driver profile.');
    } catch (err: any) {
      setError(err?.message || 'Failed to save license details');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <PageHeader title="Driver License" subtitle="Your license and verification details" />

      <form className="p2-card" style={{ maxWidth: '640px' }} onSubmit={handleSave}>
        {loading && <p style={{ color: '#6b7c8f' }}>Loading profile…</p>}
        {error && <p style={{ color: '#b91c1c', marginBottom: '1rem' }}>{error}</p>}
        {message && <p style={{ color: '#047857', marginBottom: '1rem' }}>{message}</p>}

        <div className="p2-form-group">
          <label className="p2-form-label">License Number</label>
          <input
            className="p2-input"
            placeholder="Enter license number"
            value={licenseNumber}
            onChange={(e) => setLicenseNumber(e.target.value)}
            required
          />
        </div>
        <div className="p2-form-group">
          <label className="p2-form-label">License Class</label>
          <select
            className="p2-select"
            value={licenseClass}
            onChange={(e) => setLicenseClass(e.target.value)}
          >
            <option value="">Select class</option>
            <option value="C">Class C — Heavy Truck</option>
            <option value="D">Class D — Trailer</option>
          </select>
        </div>
        <p style={{ color: '#6b7c8f', fontSize: '0.875rem', marginBottom: '1rem' }}>
          Saved via <code>PUT /drivers/profile</code>. Full KYC document upload remains separate.
        </p>
        <button type="submit" className="btn-primary" disabled={saving || loading}>
          {saving ? 'Saving…' : 'Save License Info'}
        </button>
      </form>
    </div>
  );
}

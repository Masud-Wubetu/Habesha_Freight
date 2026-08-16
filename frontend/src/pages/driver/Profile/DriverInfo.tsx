import { useEffect, useState } from 'react';
import ErrorState from '../../../components/ErrorState';
import LoadingState from '../../../components/LoadingState';
import PageHeader from '../../../components/PageHeader';
import { fetchCurrentUser } from '../../../services/authService';
import type { AuthUser } from '../../../types/person2';

export default function DriverInfo() {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchCurrentUser()
      .then(setUser)
      .catch((e: Error) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingState message="Loading profile..." />;
  if (error) return <ErrorState message={error} onRetry={() => window.location.reload()} />;

  return (
    <div>
      <PageHeader title="Driver Information" subtitle="Your account details" />

      <div className="p2-card" style={{ maxWidth: '640px' }}>
        <div style={{ display: 'flex', gap: '1.25rem', alignItems: 'center', marginBottom: '1.5rem' }}>
          <div className="p2-user-avatar" style={{ width: 72, height: 72, fontSize: '1.75rem' }}>
            {(user?.full_name ?? 'D').charAt(0)}
          </div>
          <div>
            <h3 style={{ fontFamily: 'Instrument Serif, serif' }}>{user?.full_name}</h3>
            <p style={{ color: '#6b7c8f' }}>{user?.role}</p>
          </div>
        </div>
        {[
          ['Full Name', user?.full_name],
          ['Phone', user?.phone_number],
          ['Email', user?.email ?? '—'],
          ['Verified', user?.is_verified ? 'Yes' : 'No'],
        ].map(([label, value]) => (
          <div key={String(label)} className="p2-detail-row">
            <span className="p2-detail-label">{label}</span>
            <span className="p2-detail-value">{value}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

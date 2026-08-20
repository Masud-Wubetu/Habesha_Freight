import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import '../../styles/driver-dashboard.css';
import { useDriverStats } from '../../hooks/useDriverStats';
import { useAvailableLoads } from '../../hooks/useAvailableLoads';
import { useDriverShipments } from '../../hooks/useDriverShipments';
import { getStoredUser } from '../../services/authService';

const formatCurrency = (n: number) => `ETB ${Number(n).toLocaleString()}`;

const today = new Date().toLocaleDateString('en-US', {
  weekday: 'long',
  month: 'short',
  day: 'numeric',
  year: 'numeric',
});

const DriverDashboard: React.FC = () => {
  const navigate = useNavigate();
  const user = getStoredUser();
  const initials = (user?.full_name ?? 'AG')
    .split(' ')
    .map((w) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  const { stats, loading: statsLoading } = useDriverStats();
  const { loads, loading: loadsLoading } = useAvailableLoads();
  const { shipments } = useDriverShipments();

  const [isOnline, setIsOnline] = useState(true);

  // Active shipment is first one that is not DELIVERED/CANCELLED
  const activeShipment = shipments.find(
    (s) => !['DELIVERED', 'CANCELLED'].includes(s.status)
  );

  return (
    <div className="dd-root">

      {/* ── Top header ─────────────────────────────────────────────────── */}
      <header className="dd-header">
        <div>
          <h1 className="dd-header-title">Dashboard</h1>
          <p className="dd-header-date">{today}</p>
        </div>

        <div className="dd-header-actions">
          <button
            id="dd-availability-toggle"
            className={`dd-availability-badge ${isOnline ? 'dd-availability-badge--online' : 'dd-availability-badge--offline'}`}
            onClick={() => setIsOnline((v) => !v)}
            type="button"
          >
            <span className="dd-availability-dot" />
            {isOnline ? 'Online & Available' : 'Offline'}
          </button>

          <button
            id="dd-profile-btn"
            className="dd-avatar-btn"
            type="button"
            aria-label="Profile"
            onClick={() => navigate('/driver/profile')}
          >
            {initials}
          </button>
        </div>
      </header>

      {/* ── Stat cards ─────────────────────────────────────────────────── */}
      <section className="dd-stats-grid" aria-label="Statistics">
        <article className="dd-stat-card" style={{ cursor: 'pointer' }} onClick={() => navigate('/driver/bids')}>
          <div className="dd-stat-icon dd-stat-icon--amber">💰</div>
          <p className="dd-stat-value">
            {statsLoading ? '…' : formatCurrency(stats?.totalEarningsEtb ?? 0)}
          </p>
          <p className="dd-stat-label">Total Earnings</p>
        </article>

        <article className="dd-stat-card" style={{ cursor: 'pointer' }} onClick={() => navigate('/driver/active-delivery')}>
          <div className="dd-stat-icon dd-stat-icon--blue">🚛</div>
          <p className="dd-stat-value">{statsLoading ? '…' : stats?.activeJobs ?? 0}</p>
          <p className="dd-stat-label">Active Jobs</p>
        </article>

        <article className="dd-stat-card" style={{ cursor: 'pointer' }} onClick={() => navigate('/driver/history')}>
          <div className="dd-stat-icon dd-stat-icon--green">✅</div>
          <p className="dd-stat-value">{statsLoading ? '…' : stats?.totalTrips ?? 0}</p>
          <p className="dd-stat-label">Total Trips</p>
        </article>

        <article className="dd-stat-card" style={{ cursor: 'pointer' }} onClick={() => navigate('/driver/ratings')}>
          <div className="dd-stat-icon dd-stat-icon--gold">🏅</div>
          <p className="dd-stat-value">
            {statsLoading ? '…' : (stats?.avgRating ?? 'N/A')}{' '}
            {stats?.avgRating ? <span className="dd-star">⭐</span> : null}
          </p>
          <p className="dd-stat-label">Rating</p>
        </article>
      </section>

      {/* ── Active Job dark card ─────────────────────────────────────── */}
      {activeShipment ? (
        <section className="dd-active-job-card" aria-label="Active job">
          <div className="dd-active-job-top">
            <div className="dd-active-job-meta">
              <span className="dd-active-job-eyebrow">Active Job</span>
              <h2 className="dd-active-job-title">
                {activeShipment.id.slice(0, 8)}… · {activeShipment.origin_city} → {activeShipment.destination_city}
              </h2>
              <p className="dd-active-job-sub">
                {activeShipment.cargo_description} · {activeShipment.weight_tons} t
              </p>
            </div>
            <span className="dd-status-chip dd-status-chip--transit">
              {activeShipment.status}
            </span>
          </div>

          <div className="dd-active-job-actions">
            <button
              id="dd-navigation-btn"
              className="dd-action-btn dd-action-btn--dark"
              type="button"
              onClick={() => navigate('/driver/history/tracking')}
            >
              📍 Navigation
            </button>
            <button
              id="dd-manage-delivery-btn"
              className="dd-action-btn dd-action-btn--gold"
              type="button"
              onClick={() => navigate('/driver/active-delivery')}
            >
              🚚 Manage Delivery
            </button>
          </div>
        </section>
      ) : (
        <section className="dd-active-job-card" aria-label="No active job">
          <p style={{ color: 'rgba(255,255,255,0.6)', textAlign: 'center', padding: '1rem' }}>
            No active delivery — browse loads below to bid.
          </p>
        </section>
      )}

      {/* ── Available Loads ──────────────────────────────────────────── */}
      <section className="dd-card" aria-label="Available loads nearby">
        <div className="dd-section-header">
          <h3 className="dd-section-title">Available Loads Nearby</h3>
          <button
            id="dd-view-all-loads-btn"
            className="dd-link-btn"
            type="button"
            onClick={() => navigate('/driver/requests/loads')}
          >
            View all
          </button>
        </div>

        {loadsLoading ? (
          <p style={{ color: 'rgba(255,255,255,0.5)', padding: '1rem 0' }}>Loading loads…</p>
        ) : loads.length === 0 ? (
          <p style={{ color: 'rgba(255,255,255,0.5)', padding: '1rem 0' }}>No available loads at the moment.</p>
        ) : (
          <ul className="dd-load-list">
            {loads.slice(0, 5).map((load) => (
              <li
                key={load.id}
                className="dd-load-item"
                style={{ cursor: 'pointer' }}
                onClick={() => navigate(`/driver/requests/${load.id}`)}
              >
                <div className="dd-load-icon">📦</div>
                <div className="dd-load-info">
                  <p className="dd-load-route">
                    {load.origin_city} → {load.destination_city}
                  </p>
                  <p className="dd-load-sub">
                    {load.cargo_description} · {load.weight_tons} t
                  </p>
                </div>
                <div className="dd-load-price-col">
                  <p className="dd-load-price">{formatCurrency(load.offered_price_etb)}</p>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>

      {/* ── Pending Bids ─────────────────────────────────────────────── */}
      <section className="dd-card" aria-label="Pending bids">
        <div className="dd-section-header">
          <h3 className="dd-section-title">Pending Bids</h3>
          <button
            id="dd-view-all-bids-btn"
            className="dd-link-btn"
            type="button"
            onClick={() => navigate('/driver/bids')}
          >
            View all
          </button>
        </div>
        {statsLoading ? (
          <p style={{ color: 'rgba(255,255,255,0.5)', padding: '1rem 0' }}>Loading…</p>
        ) : (
          <p style={{ color: 'rgba(255,255,255,0.7)', padding: '0.5rem 0' }}>
            You have <strong>{stats?.pendingBids ?? 0}</strong> pending bid(s) awaiting shipper response.
          </p>
        )}
      </section>

    </div>
  );
};

export default DriverDashboard;
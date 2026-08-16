import React, { useState } from 'react';
import '../../../styles/driver-dashboard.css';

// ── Types ──────────────────────────────────────────────────────────────────
type JobStatus = 'In Transit' | 'Loaded' | 'At Checkpoint' | 'Delivered';

interface ActiveJob {
  id: string;
  origin: string;
  destination: string;
  cargo: string;
  weight: string;
  status: JobStatus;
}

interface AvailableLoad {
  id: string;
  origin: string;
  destination: string;
  cargo: string;
  weight: string;
  price: number;
  distance: number;
}

// ── Static data (replace with API calls in production) ────────────────────
const ACTIVE_JOB: ActiveJob = {
  id: 'SHP-001',
  origin: 'Addis Ababa',
  destination: 'Dire Dawa',
  cargo: 'Electronics',
  weight: '8 tons',
  status: 'In Transit',
};

const AVAILABLE_LOADS: AvailableLoad[] = [
  {
    id: '1',
    origin: 'Addis Ababa',
    destination: 'Hawassa',
    cargo: 'Agricultural Produce',
    weight: '12 tons',
    price: 9200,
    distance: 275,
  },
  {
    id: '2',
    origin: 'Adama',
    destination: 'Dire Dawa',
    cargo: 'Electronics',
    weight: '5 tons',
    price: 6800,
    distance: 340,
  },
  {
    id: '3',
    origin: 'Addis Ababa',
    destination: 'Bahir Dar',
    cargo: 'Construction Materials',
    weight: '22 tons',
    price: 16000,
    distance: 510,
  },
];

// ── Helpers ───────────────────────────────────────────────────────────────
const formatCurrency = (n: number) =>
  `ETB ${n.toLocaleString()}`;

const today = new Date().toLocaleDateString('en-US', {
  weekday: 'long',
  month: 'short',
  day: 'numeric',
  year: 'numeric',
});

// ── Component ─────────────────────────────────────────────────────────────
const DriverDashboard: React.FC = () => {
  const [jobStatus, setJobStatus] = useState<JobStatus>(ACTIVE_JOB.status);
  const [isOnline, setIsOnline] = useState(true);

  const activeJob = { ...ACTIVE_JOB, status: jobStatus };

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
            id="dd-dark-mode-btn"
            className="dd-icon-btn"
            type="button"
            aria-label="Toggle dark mode"
          >
            🌙
          </button>

          <button
            id="dd-profile-btn"
            className="dd-avatar-btn"
            type="button"
            aria-label="Profile"
          >
            AG
          </button>
        </div>
      </header>

      {/* ── Stat cards ─────────────────────────────────────────────────── */}
      <section className="dd-stats-grid" aria-label="Statistics">
        <article className="dd-stat-card">
          <div className="dd-stat-icon dd-stat-icon--amber">💰</div>
          <p className="dd-stat-value">ETB 8,500</p>
          <p className="dd-stat-label">This Month</p>
        </article>

        <article className="dd-stat-card">
          <div className="dd-stat-icon dd-stat-icon--blue">🚛</div>
          <p className="dd-stat-value">1</p>
          <p className="dd-stat-label">Active Jobs</p>
        </article>

        <article className="dd-stat-card">
          <div className="dd-stat-icon dd-stat-icon--green">✅</div>
          <p className="dd-stat-value">142</p>
          <p className="dd-stat-label">Total Trips</p>
        </article>

        <article className="dd-stat-card">
          <div className="dd-stat-icon dd-stat-icon--gold">🏅</div>
          <p className="dd-stat-value">
            4.8 <span className="dd-star">⭐</span>
          </p>
          <p className="dd-stat-label">Rating</p>
        </article>
      </section>

      {/* ── Active Job dark card ────────────────────────────────────────── */}
      <section className="dd-active-job-card" aria-label="Active job">
        <div className="dd-active-job-top">
          <div className="dd-active-job-meta">
            <span className="dd-active-job-eyebrow">Active Job</span>
            <h2 className="dd-active-job-title">
              {activeJob.id} · {activeJob.origin} → {activeJob.destination}
            </h2>
            <p className="dd-active-job-sub">
              {activeJob.cargo} · {activeJob.weight}
            </p>
          </div>
          <span className="dd-status-chip dd-status-chip--transit">
            {activeJob.status}
          </span>
        </div>

        <div className="dd-active-job-actions">
          <button
            id="dd-navigation-btn"
            className="dd-action-btn dd-action-btn--dark"
            type="button"
          >
            📍 Navigation
          </button>
          <button
            id="dd-manage-delivery-btn"
            className="dd-action-btn dd-action-btn--gold"
            type="button"
          >
            🚚 Manage Delivery
          </button>
        </div>
      </section>

      {/* ── Available Loads ─────────────────────────────────────────────── */}
      <section className="dd-card" aria-label="Available loads nearby">
        <div className="dd-section-header">
          <h3 className="dd-section-title">Available Loads Nearby</h3>
          <button
            id="dd-view-all-loads-btn"
            className="dd-link-btn"
            type="button"
          >
            View all
          </button>
        </div>

        <ul className="dd-load-list">
          {AVAILABLE_LOADS.map((load) => (
            <li key={load.id} className="dd-load-item">
              <div className="dd-load-icon">📦</div>
              <div className="dd-load-info">
                <p className="dd-load-route">
                  {load.origin} → {load.destination}
                </p>
                <p className="dd-load-sub">
                  {load.cargo} · {load.weight}
                </p>
              </div>
              <div className="dd-load-price-col">
                <p className="dd-load-price">{formatCurrency(load.price)}</p>
                <p className="dd-load-distance">{load.distance} km</p>
              </div>
            </li>
          ))}
        </ul>
      </section>

      {/* ── Update Job Status ───────────────────────────────────────────── */}
      <section className="dd-card" aria-label="Update job status">
        <h3 className="dd-section-title">Update Job Status</h3>
        <p className="dd-status-hint">
          {activeJob.id} is currently{' '}
          <strong>{activeJob.status}</strong>. Update when you reach
          the next milestone.
        </p>

        <div className="dd-status-actions">
          <button
            id="dd-mark-loaded-btn"
            className="dd-milestone-btn"
            type="button"
            onClick={() => setJobStatus('Loaded')}
          >
            Mark as Loaded →
          </button>
          <button
            id="dd-checkpoint-btn"
            className="dd-milestone-btn"
            type="button"
            onClick={() => setJobStatus('At Checkpoint')}
          >
            Arrived at Checkpoint →
          </button>
          <button
            id="dd-mark-delivered-btn"
            className="dd-milestone-btn"
            type="button"
            onClick={() => setJobStatus('Delivered')}
          >
            Mark as Delivered →
          </button>
        </div>
      </section>

    </div>
  );
};

export default DriverDashboard;
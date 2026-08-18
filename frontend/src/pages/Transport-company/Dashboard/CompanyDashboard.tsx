import { useState } from 'react';
import { Link } from 'react-router-dom';
import './CompanyDashboard.css';

/* ── Static mock data matching the UI screenshots ── */
const STATS = [
  { icon: '🚛', value: '5', label: 'Fleet Size', color: 'stat-blue' },
  { icon: '✅', value: '3', label: 'Available Trucks', color: 'stat-green' },
  { icon: '🚚', value: '2', label: 'Active Deliveries', color: 'stat-orange' },
  { icon: '📋', value: '1', label: 'Pending Requests', color: 'stat-purple' },
  { icon: '👤', value: '4', label: 'Total Drivers', color: 'stat-blue' },
  { icon: '🤝', value: '115', label: 'Completed Trips', color: 'stat-green' },
  { icon: '🔥', value: 'ETB 142K', label: 'This Month Revenue', color: 'stat-orange' },
  { icon: '⭐', value: '4.8', label: 'Average Rating', color: 'stat-star' },
];

const FLEET_REQUESTS = [
  { id: 'FR-001', trucks: '3 trucks', from: 'Addis Ababa', to: 'Dire Dawa', status: 'Pending', statusClass: 'badge-pending' },
  { id: 'FR-002', trucks: '2 trucks', from: 'Adama', to: 'Hawassa', status: 'Accepted', statusClass: 'badge-accepted' },
  { id: 'FR-003', trucks: '5 trucks', from: 'Addis', to: 'Mekelle', status: 'In Progress', statusClass: 'badge-inprogress' },
];

const FLEET_STATUS = [
  { plate: 'AAU-3421', model: 'Isuzu FSR', driver: 'Abebe Girma', status: 'Available', statusClass: 'badge-available' },
  { plate: 'AA-45892', model: 'Mercedes Actros', driver: 'Tesfaye Haile', status: 'In Transit', statusClass: 'badge-intransit' },
  { plate: 'AA-11034', model: 'Volvo FH', driver: 'Selam Tadesse', status: 'Available', statusClass: 'badge-available' },
  { plate: 'AA-77821', model: 'Isuzu NPR', driver: 'Unassigned', status: 'Maintenance', statusClass: 'badge-maintenance' },
  { plate: 'AA-92340', model: 'Sino Howo', driver: 'Kibru Alemu', status: 'In Transit', statusClass: 'badge-intransit' },
];

/* Day/date helpers */
function getFormattedDate() {
  const d = new Date();
  return d.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' });
}

export default function CompanyDashboard() {
  const [darkMode, setDarkMode] = useState(false);

  return (
    <div className={`co-dash ${darkMode ? 'co-dash--dark' : ''}`}>

      {/* ── Page header ── */}
      <div className="co-header">
        <div>
          <h1 className="co-title">Dashboard</h1>
          <p className="co-date">{getFormattedDate()}</p>
        </div>
        <div className="co-header-actions">
          <button id="co-pending-btn" className="co-pending-btn" type="button">
            <span>📋</span> 1 pending request
          </button>
          <button
            id="co-darkmode-btn"
            className="co-icon-btn"
            type="button"
            aria-label="Toggle dark mode"
            onClick={() => setDarkMode((v) => !v)}
          >
            {darkMode ? '☀️' : '🌙'}
          </button>
          <div className="co-avatar" aria-label="Company avatar">ET</div>
        </div>
      </div>

      {/* ── Stats grid ── */}
      <div className="co-stats-grid">
        {STATS.map((s) => (
          <div key={s.label} className="co-stat-card">
            <div className={`co-stat-icon ${s.color}`}>{s.icon}</div>
            <div className="co-stat-value">
              {s.label === 'Average Rating' ? (
                <>
                  {s.value} <span className="co-star">⭐</span>
                </>
              ) : s.value}
            </div>
            <div className="co-stat-label">{s.label}</div>
          </div>
        ))}
      </div>

      {/* ── Bottom two-column section ── */}
      <div className="co-bottom-grid">

        {/* Recent Fleet Requests */}
        <div className="co-card">
          <div className="co-card-header">
            <h2 className="co-card-title">Recent Fleet Requests</h2>
            <Link to="/company/fleet-requests" className="co-view-all">View all</Link>
          </div>
          <div className="co-list">
            {FLEET_REQUESTS.map((req) => (
              <div key={req.id} className="co-list-row">
                <div className="co-list-info">
                  <div className="co-list-main">
                    <span className="co-req-id">{req.id}</span>
                    {' · '}
                    <span className="co-req-trucks">{req.trucks}</span>
                  </div>
                  <div className="co-list-sub">
                    {req.from} → {req.to}
                  </div>
                </div>
                <span className={`co-badge ${req.statusClass}`}>{req.status}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Fleet Status */}
        <div className="co-card">
          <div className="co-card-header">
            <h2 className="co-card-title">Fleet Status</h2>
            <Link to="/company/vehicles" className="co-view-all">Manage fleet</Link>
          </div>
          <div className="co-list">
            {FLEET_STATUS.map((v) => (
              <div key={v.plate} className="co-list-row">
                <div className="co-list-info">
                  <div className="co-list-main">
                    <span className="co-vehicle-plate">{v.plate}</span>
                    {' · '}
                    <span>{v.model}</span>
                  </div>
                  <div className={`co-list-sub ${v.driver === 'Unassigned' ? 'co-unassigned' : ''}`}>
                    {v.driver}
                  </div>
                </div>
                <span className={`co-badge ${v.statusClass}`}>{v.status}</span>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}

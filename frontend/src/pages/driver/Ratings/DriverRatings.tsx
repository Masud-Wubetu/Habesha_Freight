import PageHeader from '../../../components/PageHeader';

export default function DriverRatings() {
  // TODO: Replace with API response from GET /api/driver/ratings

  return (
    <div>
      <PageHeader title="Ratings & Reviews" subtitle="Feedback from shippers and fleet owners" />

      <div className="p2-grid p2-grid--3" style={{ marginBottom: '1.5rem' }}>
        <div className="p2-stat-card p2-stat-card--gold">
          <span className="p2-stat-label">Average Rating</span>
          <span className="p2-stat-value">—</span>
        </div>
        <div className="p2-stat-card p2-stat-card--navy">
          <span className="p2-stat-label">Total Reviews</span>
          <span className="p2-stat-value">0</span>
        </div>
        <div className="p2-stat-card p2-stat-card--green">
          <span className="p2-stat-label">5-Star Reviews</span>
          <span className="p2-stat-value">0</span>
        </div>
      </div>

      <div className="p2-card">
        <h3 style={{ fontFamily: 'Instrument Serif, serif', marginBottom: '1rem' }}>Recent Reviews</h3>
        <p style={{ color: '#6b7c8f' }}>No reviews yet. Complete deliveries to receive ratings.</p>
      </div>
    </div>
  );
}

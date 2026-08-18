import PageHeader from '../../components/PageHeader';

export default function LiveTracking() {
  // TODO: Integrate with backend location data via GET /api/driver/deliveries/:id/tracking
  // TODO: Use existing map library when backend provides coordinates

  return (
    <div>
      <PageHeader
        title="Live Tracking"
        subtitle="Real-time location of your active delivery"
      />

      <div className="p2-map-placeholder">
        <div style={{ textAlign: 'center', padding: '1rem' }}>
          <p style={{ fontWeight: 600, marginBottom: '0.5rem' }}>Map integration pending</p>
          <p style={{ fontSize: '0.875rem' }}>
            Live GPS tracking will display here once the backend provides location updates.
          </p>
        </div>
      </div>

      <div className="p2-card" style={{ marginTop: '1rem' }}>
        <h3 style={{ fontFamily: 'Instrument Serif, serif', marginBottom: '0.75rem' }}>
          Tracking Info
        </h3>
        <div className="p2-detail-row">
          <span className="p2-detail-label">Last Update</span>
          <span className="p2-detail-value">—</span>
        </div>
        <div className="p2-detail-row">
          <span className="p2-detail-label">Current Location</span>
          <span className="p2-detail-value">—</span>
        </div>
        <div className="p2-detail-row">
          <span className="p2-detail-label">Speed</span>
          <span className="p2-detail-value">—</span>
        </div>
      </div>
    </div>
  );
}

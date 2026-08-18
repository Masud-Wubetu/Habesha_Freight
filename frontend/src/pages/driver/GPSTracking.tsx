import { useNavigate } from 'react-router-dom';
import '../../styles/active-delivery.css';

/**
 * GPS Navigation / Live Tracking page
 * ─────────────────────────────────────
 * Placeholder for the GPS tracking feature.
 * TODO: Integrate Google Maps / Mapbox via GET /api/driver/deliveries/:id/location
 *       and WebSocket /ws/driver/location for real-time position updates.
 */
export default function GPSTracking() {
  const navigate = useNavigate();

  // TODO: pull live data from context / API
  const delivery = {
    shipmentId: 'SHP-001',
    origin: 'Addis Ababa',
    destination: 'Dire Dawa',
    currentLocation: 'Near Adama, Oromia Region',  // TODO: real coords from API
    speed: '—',           // TODO: km/h from GPS feed
    distanceLeft: '—',    // TODO: calculated from API coords
    eta: '—',             // TODO: from routing API
    lastUpdate: 'Awaiting GPS signal…',
  };

  return (
    <div className="gps-page">

      {/* Back button */}
      <button className="gps-back-btn" onClick={() => navigate('/driver/active-delivery')}>
        ← Back to Active Delivery
      </button>

      {/* Header */}
      <div className="gps-header">
        <h1>Navigation</h1>
        <p>{delivery.shipmentId} · {delivery.origin} → {delivery.destination}</p>
      </div>

      {/* API placeholder notice */}
      <div className="gps-api-notice">
        <span className="gps-api-notice-icon">🔧</span>
        <div>
          <strong>GPS API Integration Pending</strong>
          Live tracking will be enabled once connected to the location service.
          Replace the placeholder below with a real map component (Google Maps / Mapbox).
        </div>
      </div>

      {/* Map placeholder */}
      <div className="gps-map">
        {/* TODO: Replace entire .gps-map div with <MapComponent /> once API is ready */}
        <div className="gps-map-inner">
          <span className="gps-map-pin">📍</span>
          <div className="gps-map-label">
            {delivery.currentLocation}
            <div className="gps-map-sublabel">GPS placeholder — real map goes here</div>
          </div>
        </div>

        {/* Origin / Destination markers */}
        <div className="gps-route-markers">
          <div className="gps-marker">
            <span className="gps-marker-dot gps-marker-dot--start" />
            {delivery.origin}
          </div>
          <div className="gps-marker">
            <span className="gps-marker-dot gps-marker-dot--end" />
            {delivery.destination}
          </div>
        </div>
      </div>

      {/* Stats cards */}
      <div className="gps-stats">
        <div className="gps-stat-card">
          <div className="gps-stat-icon">🚀</div>
          <p className="gps-stat-value">{delivery.speed}</p>
          <p className="gps-stat-label">Current Speed</p>
        </div>
        <div className="gps-stat-card">
          <div className="gps-stat-icon">📏</div>
          <p className="gps-stat-value">{delivery.distanceLeft}</p>
          <p className="gps-stat-label">Distance Left</p>
        </div>
        <div className="gps-stat-card">
          <div className="gps-stat-icon">🕐</div>
          <p className="gps-stat-value">{delivery.eta}</p>
          <p className="gps-stat-label">ETA</p>
        </div>
      </div>

      {/* Info rows */}
      <div className="gps-info-card">
        <div className="gps-info-row">
          <span className="gps-info-label">Shipment ID</span>
          <span className="gps-info-value">{delivery.shipmentId}</span>
        </div>
        <div className="gps-info-row">
          <span className="gps-info-label">Route</span>
          <span className="gps-info-value">{delivery.origin} → {delivery.destination}</span>
        </div>
        <div className="gps-info-row">
          <span className="gps-info-label">Current Location</span>
          <span className="gps-info-value">{delivery.currentLocation}</span>
        </div>
        <div className="gps-info-row">
          <span className="gps-info-label">Last GPS Update</span>
          <span className="gps-info-value">{delivery.lastUpdate}</span>
        </div>
      </div>
    </div>
  );
}

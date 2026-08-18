import { useParams, Link } from 'react-router-dom';
import PageHeader from '../../components/PageHeader';
import StatusBadge from '../../components/StatusBadge';

export default function RequestDetails() {
  const { id } = useParams<{ id: string }>();

  // TODO: Replace with API response from GET /api/driver/requests/:id
  const request = {
    id: id ?? '',
    origin: 'Addis Ababa',
    destination: 'Dire Dawa',
    cargoType: 'General Cargo',
    weight: 12,
    pickupDate: '2026-08-20',
    deliveryDate: '2026-08-22',
    status: 'open',
    description: 'Standard palletized goods requiring covered truck.',
    shipper: 'ABC Trading PLC',
  };

  return (
    <div>
      <PageHeader
        title="Request Details"
        subtitle={`Request #${request.id.slice(0, 8)}`}
        actions={
          <Link to="/driver/bids/submit" state={{ requestId: id }} className="btn-primary">
            Submit Bid
          </Link>
        }
      />

      <div className="p2-detail-grid">
        <div className="p2-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
            <h3 style={{ fontFamily: 'Instrument Serif, serif' }}>Shipment Information</h3>
            <StatusBadge status={request.status} />
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Route</span>
            <span className="p2-detail-value">{request.origin} → {request.destination}</span>
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Cargo Type</span>
            <span className="p2-detail-value">{request.cargoType}</span>
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Weight</span>
            <span className="p2-detail-value">{request.weight} tons</span>
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Pickup Date</span>
            <span className="p2-detail-value">{request.pickupDate}</span>
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Delivery Date</span>
            <span className="p2-detail-value">{request.deliveryDate}</span>
          </div>
          <div className="p2-detail-row">
            <span className="p2-detail-label">Shipper</span>
            <span className="p2-detail-value">{request.shipper}</span>
          </div>
          <p style={{ marginTop: '1rem', color: '#5a6a7a', fontSize: '0.9rem' }}>{request.description}</p>
        </div>

        <div className="p2-card">
          <h3 style={{ fontFamily: 'Instrument Serif, serif', marginBottom: '1rem' }}>Actions</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            <Link to="/driver/bids/submit" state={{ requestId: id }} className="btn-primary" style={{ textAlign: 'center' }}>
              Submit Bid
            </Link>
            <Link to="/driver/requests/loads" className="btn-outline" style={{ textAlign: 'center' }}>
              Back to Loads
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

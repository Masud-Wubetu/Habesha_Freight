import { Link } from 'react-router-dom';
import EmptyState from '../../../components/EmptyState';
import PageHeader from '../../../components/PageHeader';
import StatusBadge from '../../../components/StatusBadge';

export default function ActiveDelivery() {
  // TODO: Replace with API response from GET /api/driver/deliveries/active
  const delivery = null as {
    id: string;
    origin: string;
    destination: string;
    status: string;
    eta: string;
    cargoType: string;
  } | null;

  if (!delivery) {
    return (
      <div>
        <PageHeader title="Active Delivery" subtitle="Your current in-progress delivery" />
        <EmptyState
          title="No active delivery"
          description="When you are assigned a delivery, it will appear here with status updates and tracking."
          action={
            <Link to="/driver/requests/loads" className="btn-primary">
              Find Loads
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Active Delivery"
        subtitle={`Delivery #${delivery.id.slice(0, 8)}`}
        actions={
          <>
            <Link to="/driver/deliveries/tracking" className="btn-primary">
              Live Tracking
            </Link>
            <Link to={`/driver/deliveries/${delivery.id}`} className="btn-outline">
              Details
            </Link>
          </>
        }
      />

      <div className="p2-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
          <h3 style={{ fontFamily: 'Instrument Serif, serif' }}>
            {delivery.origin} → {delivery.destination}
          </h3>
          <StatusBadge status={delivery.status} />
        </div>
        <div className="p2-detail-row">
          <span className="p2-detail-label">Cargo</span>
          <span className="p2-detail-value">{delivery.cargoType}</span>
        </div>
        <div className="p2-detail-row">
          <span className="p2-detail-label">ETA</span>
          <span className="p2-detail-value">{delivery.eta}</span>
        </div>
      </div>
    </div>
  );
}

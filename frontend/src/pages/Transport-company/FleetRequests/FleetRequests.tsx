import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './FleetRequests.css';

type RequestStatus =
  | 'Pending'
  | 'Accepted'
  | 'In Progress'
  | 'Completed'
  | 'Declined';

interface FleetRequest {
  id: string;
  customer: string;
  date: string;
  from: string;
  to: string;
  cargo: string;
  trucks: number;
  amount: string;
  status: RequestStatus;
}

const INITIAL_REQUESTS: FleetRequest[] = [
  {
    id: 'FR-001',
    customer: 'Tigist Worku',
    date: 'Aug 12',
    from: 'Addis Ababa',
    to: 'Dire Dawa',
    cargo: 'Construction Materials',
    trucks: 3,
    amount: 'ETB 42,000',
    status: 'Pending',
  },
  {
    id: 'FR-002',
    customer: 'Yohannes Alemu',
    date: 'Aug 10',
    from: 'Adama',
    to: 'Hawassa',
    cargo: 'Agricultural Goods',
    trucks: 2,
    amount: 'ETB 28,500',
    status: 'Accepted',
  },
  {
    id: 'FR-003',
    customer: 'Sara Bekele',
    date: 'Aug 8',
    from: 'Addis',
    to: 'Mekelle',
    cargo: 'Industrial Equipment',
    trucks: 5,
    amount: 'ETB 75,000',
    status: 'In Progress',
  },
  {
    id: 'FR-004',
    customer: 'Dawit Haile',
    date: 'Aug 5',
    from: 'Bahir Dar',
    to: 'Addis',
    cargo: 'Perishable Goods',
    trucks: 1,
    amount: 'ETB 14,200',
    status: 'Completed',
  },
];

const statusClass: Record<RequestStatus, string> = {
  Pending: 'fr-badge fr-badge-pending',
  Accepted: 'fr-badge fr-badge-accepted',
  'In Progress': 'fr-badge fr-badge-progress',
  Completed: 'fr-badge fr-badge-completed',
  Declined: 'fr-badge fr-badge-declined',
};

export default function FleetRequests() {
  const navigate = useNavigate();

  const [requests, setRequests] = useState<FleetRequest[]>(
    INITIAL_REQUESTS
  );


  const handleAccept = (id: string) => {
    setRequests((current) =>
      current.map((request) =>
        request.id === id
          ? { ...request, status: 'Accepted' }
          : request
      )
    );
  };

  const handleDecline = (id: string) => {
    setRequests((current) =>
      current.map((request) =>
        request.id === id
          ? { ...request, status: 'Declined' }
          : request
      )
    );
  };

  return (
    <div className="fr-page">
      <div className="fr-content">
        {requests.map((request) => (
          <article className="fr-request-card" key={request.id}>
            {/* Top row */}
            <div className="fr-card-top">
              <div className="fr-request-heading">
                <div className="fr-title-row">
                  <h2>{request.id}</h2>

                  <span className={statusClass[request.status]}>
                    {request.status}
                  </span>
                </div>

                <p className="fr-customer">
                  {request.customer} <span>·</span> {request.date}
                </p>
              </div>

              <div className="fr-price">
                <strong>{request.amount}</strong>
                <span>
                  {request.trucks} truck
                  {request.trucks !== 1 ? 's' : ''} required
                </span>
              </div>
            </div>

            {/* Request information */}
            <div className="fr-details-grid">
              <div className="fr-detail">
                <span className="fr-detail-icon">📍</span>
                <span>
                  {request.from} → {request.to}
                </span>
              </div>

              <div className="fr-detail">
                <span className="fr-detail-icon">📦</span>
                <span>{request.cargo}</span>
              </div>

              <div className="fr-detail">
                <span className="fr-detail-icon">🚚</span>
                <span>
                  {request.trucks} truck
                  {request.trucks !== 1 ? 's' : ''} needed
                </span>
              </div>
            </div>

            {/* Actions */}
            {request.status === 'Pending' && (
              <div className="fr-actions fr-actions-two">
                <button
                  type="button"
                  className="fr-btn fr-btn-primary"
                  onClick={() => handleAccept(request.id)}
                >
                  Accept Request
                </button>

                <button
                  type="button"
                  className="fr-btn fr-btn-outline"
                  onClick={() => handleDecline(request.id)}
                >
                  Decline
                </button>
              </div>
            )}

            {request.status === 'Accepted' && (
              <div className="fr-actions">
                <button
                  type="button"
                  className="fr-btn fr-btn-gold"
                  onClick={() => navigate('/company/vehicles')}
                >
                  Assign Fleet →
                </button>

                <button
                  type="button"
                  className="fr-btn fr-btn-outline fr-btn-small"
                >
                  View Details
                </button>
              </div>
            )}

            {request.status === 'In Progress' && (
              <div className="fr-actions fr-actions-single">
                <button
                  type="button"
                  className="fr-btn fr-btn-outline fr-btn-small"
                >
                  View Delivery
                </button>
              </div>
            )}

            {request.status === 'Completed' && (
              <div className="fr-actions fr-actions-single">
                <button
                  type="button"
                  className="fr-btn fr-btn-outline fr-btn-small"
                >
                  View Delivery
                </button>
              </div>
            )}

            {request.status === 'Declined' && (
              <div className="fr-declined-message">
                This request was declined.
              </div>
            )}
          </article>
        ))}
      </div>
    </div>
  );
}
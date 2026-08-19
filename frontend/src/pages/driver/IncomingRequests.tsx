import { useMemo, useState } from 'react';
import { getStoredUser } from '../../services/authService';
import '../../styles/driver-requests.css';

/* ── Mock data matching the screenshot ───────────────────── */
interface FreightRequest {
  id: string;
  origin: string;
  destination: string;
  cargoType: string;
  weightTons: number;
  distanceKm: number;
  shipperName: string;
  budgetETB: number;
  isUrgent: boolean;
}

const MOCK_REQUESTS: FreightRequest[] = [
  {
    id: '1',
    origin: 'Addis Ababa',
    destination: 'Hawassa',
    cargoType: 'Agricultural Produce',
    weightTons: 12,
    distanceKm: 275,
    shipperName: 'Haile Trading',
    budgetETB: 9200,
    isUrgent: false,
  },
  {
    id: '2',
    origin: 'Adama',
    destination: 'Dire Dawa',
    cargoType: 'Electronics',
    weightTons: 5,
    distanceKm: 340,
    shipperName: 'Tigist Imports',
    budgetETB: 6800,
    isUrgent: true,
  },
  {
    id: '3',
    origin: 'Addis Ababa',
    destination: 'Bahir Dar',
    cargoType: 'Construction Materials',
    weightTons: 22,
    distanceKm: 510,
    shipperName: 'Selam Builders',
    budgetETB: 16000,
    isUrgent: false,
  },
  {
    id: '4',
    origin: 'Mekelle',
    destination: 'Addis Ababa',
    cargoType: 'General Goods',
    weightTons: 8,
    distanceKm: 780,
    shipperName: 'Kebede Store',
    budgetETB: 8500,
    isUrgent: false,
  },
  {
    id: '5',
    origin: 'Jimma',
    destination: 'Hawassa',
    cargoType: 'Coffee Beans',
    weightTons: 15,
    distanceKm: 320,
    shipperName: 'Buna Export PLC',
    budgetETB: 11500,
    isUrgent: false,
  },
  {
    id: '6',
    origin: 'Dire Dawa',
    destination: 'Addis Ababa',
    cargoType: 'Textiles',
    weightTons: 6,
    distanceKm: 450,
    shipperName: 'Merkato Fabrics',
    budgetETB: 7200,
    isUrgent: true,
  },
];

/* ── Route / city options extracted from mock data ────────── */
const ALL_ROUTES = 'All Routes';
const ALL_CARGO = 'All Cargo Types';
const ALL_DISTANCE = 'Any Distance';

const ROUTE_OPTIONS = [
  ALL_ROUTES,
  'Addis Ababa',
  'Hawassa',
  'Adama',
  'Dire Dawa',
  'Bahir Dar',
  'Mekelle',
  'Jimma',
];

const CARGO_OPTIONS = [
  ALL_CARGO,
  'Agricultural Produce',
  'Electronics',
  'Construction Materials',
  'General Goods',
  'Coffee Beans',
  'Textiles',
];

const DISTANCE_OPTIONS = [
  ALL_DISTANCE,
  'Under 300 km',
  '300 – 500 km',
  'Over 500 km',
];

/* ── Helpers ─────────────────────────────────────────────── */
function formatBudget(value: number): string {
  return value.toLocaleString('en-US');
}

function formatDate(): string {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

/* ── Chat SVG icon ───────────────────────────────────────── */
function ChatIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
    </svg>
  );
}

/* ── Component ───────────────────────────────────────────── */
export default function IncomingRequests() {
  const user = getStoredUser();

  const initials = (user?.full_name ?? 'AG')
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  /* Filters */
  const [routeFilter, setRouteFilter] = useState(ALL_ROUTES);
  const [cargoFilter, setCargoFilter] = useState(ALL_CARGO);
  const [distanceFilter, setDistanceFilter] = useState(ALL_DISTANCE);

  /* Bid modal */
  const [bidTarget, setBidTarget] = useState<FreightRequest | null>(null);
  const [bidAmount, setBidAmount] = useState('');
  const [bidNote, setBidNote] = useState('');

  /* Filter logic */
  const filtered = useMemo(() => {
    return MOCK_REQUESTS.filter((r) => {
      // Route filter — matches either origin or destination
      if (routeFilter !== ALL_ROUTES) {
        if (r.origin !== routeFilter && r.destination !== routeFilter) return false;
      }
      // Cargo type
      if (cargoFilter !== ALL_CARGO && r.cargoType !== cargoFilter) return false;
      // Distance buckets
      if (distanceFilter === 'Under 300 km' && r.distanceKm >= 300) return false;
      if (distanceFilter === '300 – 500 km' && (r.distanceKm < 300 || r.distanceKm > 500)) return false;
      if (distanceFilter === 'Over 500 km' && r.distanceKm <= 500) return false;
      return true;
    });
  }, [routeFilter, cargoFilter, distanceFilter]);

  /* Handlers */
  const openBidModal = (request: FreightRequest) => {
    setBidTarget(request);
    setBidAmount('');
    setBidNote('');
  };

  const closeBidModal = () => setBidTarget(null);

  const handleSubmitBid = () => {
    if (!bidTarget || !bidAmount) return;
    // TODO: POST /api/driver/bids  { loadId, amount, note }
    alert(`Bid of ETB ${bidAmount} submitted for ${bidTarget.origin} → ${bidTarget.destination}`);
    closeBidModal();
  };

  const handleAcceptPrice = (request: FreightRequest) => {
    // TODO: POST /api/driver/bids/accept  { loadId }
    alert(`Price accepted for ${request.origin} → ${request.destination} at ETB ${formatBudget(request.budgetETB)}`);
  };

  return (
    <div className="dr-page">

      {/* ── Header ─────────────────────────────────────────── */}
      <div className="dr-header">
        <div className="dr-header-left">
          <h1>Requests</h1>
          <p className="dr-date">{formatDate()}</p>
        </div>
        <div className="dr-header-right">
          <div className="dr-status-badge">
            <span className="dr-status-dot" />
            Online &amp; Available
          </div>
          <button className="dr-theme-toggle" aria-label="Toggle dark mode" title="Toggle dark mode">
            🌙
          </button>
          <div className="dr-avatar" title={user?.full_name ?? 'Abebe Girma'}>
            {initials}
          </div>
        </div>
      </div>

      {/* ── Filter bar ─────────────────────────────────────── */}
      <div className="dr-filters">
        <select
          className="dr-filter-select"
          value={routeFilter}
          onChange={(e) => setRouteFilter(e.target.value)}
          aria-label="Filter by route"
        >
          {ROUTE_OPTIONS.map((o) => (
            <option key={o}>{o}</option>
          ))}
        </select>

        <select
          className="dr-filter-select"
          value={cargoFilter}
          onChange={(e) => setCargoFilter(e.target.value)}
          aria-label="Filter by cargo type"
        >
          {CARGO_OPTIONS.map((o) => (
            <option key={o}>{o}</option>
          ))}
        </select>

        <select
          className="dr-filter-select"
          value={distanceFilter}
          onChange={(e) => setDistanceFilter(e.target.value)}
          aria-label="Filter by distance"
        >
          {DISTANCE_OPTIONS.map((o) => (
            <option key={o}>{o}</option>
          ))}
        </select>
      </div>

      {/* ── Request cards ──────────────────────────────────── */}
      {filtered.length === 0 ? (
        <div className="dr-empty">
          <div className="dr-empty-icon">📦</div>
          <h3>No matching requests</h3>
          <p>Try adjusting your filters to see available freight requests.</p>
        </div>
      ) : (
        <div className="dr-cards">
          {filtered.map((req) => (
            <div className="dr-card" key={req.id}>
              <div className="dr-card-top">
                <div>
                  <p className="dr-route">
                    {req.origin} <span className="dr-route-arrow">→</span> {req.destination}
                    {req.isUrgent && <span className="dr-urgent">Urgent</span>}
                  </p>
                  <p className="dr-cargo-details">
                    {req.cargoType} <span>·</span> {req.weightTons} tons <span>·</span> {req.distanceKm} km
                  </p>
                  <p className="dr-shipper">Shipper: {req.shipperName}</p>
                </div>
                <div className="dr-price-section">
                  <p className="dr-price">ETB {formatBudget(req.budgetETB)}</p>
                  <p className="dr-price-label">Posted budget</p>
                </div>
              </div>

              <div className="dr-actions">
                <button className="dr-btn-bid" onClick={() => openBidModal(req)}>
                  Submit Bid
                </button>
                <button className="dr-btn-accept" onClick={() => handleAcceptPrice(req)}>
                  Accept Price
                </button>
                <button className="dr-btn-chat" aria-label="Message shipper" title="Message shipper">
                  <ChatIcon />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* ── Bid Modal ──────────────────────────────────────── */}
      {bidTarget && (
        <div className="dr-modal-overlay" onClick={closeBidModal}>
          <div className="dr-modal" onClick={(e) => e.stopPropagation()}>
            <h2>Submit Your Bid</h2>
            <p className="dr-modal-route">
              {bidTarget.origin} → {bidTarget.destination} · {bidTarget.cargoType}
            </p>

            <label className="dr-modal-label">Your bid amount</label>
            <div className="dr-modal-input-group">
              <span className="dr-modal-currency">ETB</span>
              <input
                className="dr-modal-input"
                type="number"
                placeholder="Enter amount"
                value={bidAmount}
                onChange={(e) => setBidAmount(e.target.value)}
                autoFocus
              />
            </div>
            <p className="dr-modal-posted">
              Posted budget: <strong>ETB {formatBudget(bidTarget.budgetETB)}</strong>
            </p>

            <label className="dr-modal-label">Note (optional)</label>
            <textarea
              className="dr-modal-textarea"
              placeholder="Add a message to the shipper..."
              value={bidNote}
              onChange={(e) => setBidNote(e.target.value)}
            />

            <div className="dr-modal-actions">
              <button className="dr-modal-cancel" onClick={closeBidModal}>
                Cancel
              </button>
              <button className="dr-modal-submit" onClick={handleSubmitBid}>
                Submit Bid
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

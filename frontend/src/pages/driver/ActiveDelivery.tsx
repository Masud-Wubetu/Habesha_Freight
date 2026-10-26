import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getStoredUser } from '../../services/authService';
import { useDriverShipments } from '../../hooks/useDriverShipments';
import { post } from '../../services/api';
import ChatModal from '../../components/ChatModal';

function formatDate() {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long', month: 'short', day: 'numeric', year: 'numeric',
  });
}

export default function ActiveDelivery() {
  const navigate = useNavigate();
  const storedUser = getStoredUser();

  const initials = (storedUser?.full_name ?? 'AG')
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  type Step = 'pending' | 'loaded' | 'checkpoint' | 'delivered';
  const [step, setStep] = useState<Step>('pending');

  const [showOtpModal, setShowOtpModal] = useState(false);
  const [showPickupModal, setShowPickupModal] = useState(false);
  const [otpInput, setOtpInput] = useState('');
  const [pickupOtp, setPickupOtp] = useState('');
  const [verifyingOtp, setVerifyingOtp] = useState(false);
  const [otpMessage, setOtpMessage] = useState<string | null>(null);
  const [pickupMessage, setPickupMessage] = useState<string | null>(null);
  const [chatOpen, setChatOpen] = useState(false);

  const stepDone = (s: Step) => {
    const order: Step[] = ['pending', 'loaded', 'checkpoint', 'delivered'];
    return order.indexOf(step) > order.indexOf(s);
  };

  const { shipments } = useDriverShipments();

  const activeShipment = shipments.find(
    (s) => !['DELIVERED', 'CANCELLED'].includes(s.status)
  );

  const delivery = activeShipment
    ? {
        id: activeShipment.id,
        shipmentId: activeShipment.id.slice(0, 12),
        origin: activeShipment.origin_city ?? '—',
        destination: activeShipment.destination_city ?? '—',
        cargoType: activeShipment.cargo_description ?? 'Cargo',
        weightTons: activeShipment.weight_tons ?? 0,
        budgetETB: Number(
          (activeShipment as any).offered_price_etb ??
            (activeShipment as any).agreed_price_etb ??
            (activeShipment as any).budget_etb ??
            0,
        ),
        status: activeShipment.status,
        shipperId: String(
          (activeShipment as any).shipper_id ??
            (activeShipment as any).shipper?.id ??
            '',
        ),
        shipperName: String(
          (activeShipment as any).shipper_name ??
            (activeShipment as any).shipper?.full_name ??
            'Shipper',
        ),
      }
    : null;

  const handleVerifyPickup = async () => {
    if (!delivery) {
      setPickupMessage('No active shipment.');
      return;
    }
    if (!pickupOtp.trim()) {
      setPickupMessage('Enter the pickup OTP.');
      return;
    }
    setVerifyingOtp(true);
    setPickupMessage(null);
    try {
      await post(`/shipments/${delivery.id}/pickup-verify`, {
        pickup_otp: pickupOtp.trim(),
      });
      setPickupMessage('Pickup verified. Shipment is in transit.');
      setStep('loaded');
      setTimeout(() => {
        setShowPickupModal(false);
        setPickupMessage(null);
        setPickupOtp('');
      }, 1200);
    } catch (err: any) {
      setPickupMessage(err?.message || 'Pickup OTP verification failed.');
    } finally {
      setVerifyingOtp(false);
    }
  };

  const handleVerifyDelivery = async () => {
    if (!delivery) {
      setOtpMessage('No active shipment to verify.');
      return;
    }
    setVerifyingOtp(true);
    setOtpMessage(null);
    try {
      await post(`/shipments/${delivery.id}/delivery-verify`, {
        delivery_otp: otpInput,
      });
      setOtpMessage('Delivery verified. Escrow can be released by the shipper.');
      setStep('delivered');
      setTimeout(() => {
        setShowOtpModal(false);
        setOtpMessage(null);
      }, 1500);
    } catch (err: any) {
      console.error('Verify Delivery OTP Error:', err);
      setOtpMessage(err?.message || 'OTP verification failed. Try again.');
    } finally {
      setVerifyingOtp(false);
    }
  };

  return (
    <>
      <div className="ad-page">
        <div className="ad-header">
          <div className="ad-header-left">
            <h1>Active Delivery</h1>
            <p className="ad-date">{formatDate()}</p>
          </div>
          <div className="ad-header-right">
            <div className="ad-status-badge">
              <span className="ad-status-dot" />
              Online &amp; Available
            </div>
            <button className="ad-theme-toggle" aria-label="Toggle dark mode">🌙</button>
            <div className="ad-avatar" title={storedUser?.full_name ?? 'Driver'}>
              {initials}
            </div>
          </div>
        </div>

        {!delivery ? (
          <div className="ad-card">
            <p className="ad-shipment-meta">No active shipment from the API. Accept a load to begin delivery.</p>
          </div>
        ) : (
        <div className="ad-card">
          <div className="ad-card-top">
            <div>
              <div className="flex items-center gap-2 mb-1">
                <p className="ad-shipment-id">
                  {delivery.shipmentId} · {delivery.origin} → {delivery.destination}
                </p>
              </div>
              <p className="ad-shipment-meta">
                {delivery.cargoType} · {delivery.weightTons} tons
              </p>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: '0.4rem', marginTop: '0.4rem', backgroundColor: 'rgba(200, 147, 58, 0.15)', border: '1px solid rgba(200, 147, 58, 0.4)', borderRadius: '20px', padding: '0.25rem 0.75rem', fontSize: '0.75rem', color: '#C8933A', fontWeight: 600 }}>
                <span>🔒</span> Escrow Guaranteed Payment Active
              </div>
            </div>
            <div className="ad-price-wrap">
              {delivery.budgetETB > 0 && (
                <p className="ad-price">ETB {delivery.budgetETB.toLocaleString()}</p>
              )}
              <span className={`ad-pill ${
                step === 'delivered' ? 'ad-pill--delivered' :
                step === 'loaded'    ? 'ad-pill--loaded' :
                'ad-pill--transit'
              }`}>
                {step === 'delivered' ? 'Delivered' :
                 step === 'loaded'    ? 'Loaded' :
                 'In Transit'}
              </span>
            </div>
          </div>

          <div className="ad-actions-list">
            <div
              className={`ad-action-row ${stepDone('pending') || step === 'loaded' || step === 'checkpoint' || step === 'delivered' ? 'ad-action-row--done' : ''}`}
              onClick={() => {
                if (step === 'pending') setShowPickupModal(true);
              }}
              role="button"
              tabIndex={0}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">
                  {step === 'loaded' || step === 'checkpoint' || step === 'delivered' ? '✅' : '📦'}
                </span>
                Mark as Loaded (Pickup OTP)
              </span>
              <span className="ad-action-arrow">→</span>
            </div>

            <div
              className={`ad-action-row ${step === 'checkpoint' || step === 'delivered' ? 'ad-action-row--done' : ''}`}
              onClick={() => {
                if (step === 'loaded' || step === 'checkpoint') setStep('checkpoint');
              }}
              role="button"
              tabIndex={0}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">
                  {step === 'checkpoint' || step === 'delivered' ? '✅' : '🚩'}
                </span>
                Arrived at Checkpoint
              </span>
              <span className="ad-action-arrow">→</span>
            </div>

            <div
              className={`ad-action-row ${step === 'delivered' ? 'ad-action-row--done' : ''}`}
              onClick={() => setShowOtpModal(true)}
              role="button"
              tabIndex={0}
              style={{
                backgroundColor: step === 'delivered' ? 'rgba(34, 197, 94, 0.15)' : 'rgba(200, 147, 58, 0.15)',
                borderColor: step === 'delivered' ? '#22c55e' : '#C8933A',
                fontWeight: 600,
              }}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">{step === 'delivered' ? '✅' : '🏁'}</span>
                {step === 'delivered' ? 'Delivered & Escrow Released' : 'Mark as Delivered (Verify Receiver OTP)'}
              </span>
              <span className="ad-action-arrow">→</span>
            </div>
          </div>

          <div className="ad-bottom-actions">
            <button
              className="ad-bottom-btn"
              onClick={() => navigate('/driver/deliveries/tracking')}
            >
              <span className="ad-btn-emoji">📍</span>
              Navigation & GPS
            </button>
            <button
              className="ad-bottom-btn"
              onClick={() => {
                if (!delivery.shipperId) {
                  alert('No shipper id on this shipment — cannot open chat.');
                  return;
                }
                setChatOpen(true);
              }}
            >
              <span className="ad-btn-emoji">💬</span>
              Chat with Shipper
            </button>
          </div>
        </div>
        )}
      </div>

      {showPickupModal && (
        <div className="fixed inset-0 z-[1100] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-amber-500/40 rounded-2xl p-6 max-w-md w-full text-white shadow-2xl animate-fade-in">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <span className="text-2xl">📦</span>
                <h3 className="text-lg font-bold text-white">Pickup OTP Verification</h3>
              </div>
              <button
                onClick={() => setShowPickupModal(false)}
                className="text-white/60 hover:text-white text-xl"
              >
                ✕
              </button>
            </div>
            <p className="text-sm text-slate-300 mb-4">
              Enter the pickup OTP from the shipper to mark cargo loaded and start transit.
            </p>
            {pickupMessage && (
              <div className="p-3 mb-4 rounded-lg bg-emerald-500/20 border border-emerald-500 text-emerald-300 text-sm font-semibold">
                {pickupMessage}
              </div>
            )}
            <div className="mb-5">
              <label className="block text-xs font-semibold text-amber-400 mb-1">Pickup OTP</label>
              <input
                type="text"
                placeholder="Enter pickup OTP"
                value={pickupOtp}
                onChange={(e) => setPickupOtp(e.target.value)}
                className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-3 text-center text-xl tracking-widest font-mono text-white focus:outline-none focus:border-amber-500"
              />
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => setShowPickupModal(false)}
                className="flex-1 py-3 bg-slate-800 hover:bg-slate-700 rounded-xl text-sm font-semibold transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleVerifyPickup}
                disabled={verifyingOtp}
                className="flex-1 py-3 bg-[#C8933A] hover:bg-[#b07e2e] rounded-xl text-sm font-bold transition-colors cursor-pointer"
              >
                {verifyingOtp ? 'Verifying…' : 'Verify Pickup'}
              </button>
            </div>
          </div>
        </div>
      )}

      {showOtpModal && (
        <div className="fixed inset-0 z-[1100] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-amber-500/40 rounded-2xl p-6 max-w-md w-full text-white shadow-2xl animate-fade-in">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🔑</span>
                <h3 className="text-lg font-bold text-white">Delivery OTP Verification</h3>
              </div>
              <button
                onClick={() => setShowOtpModal(false)}
                className="text-white/60 hover:text-white text-xl"
              >
                ✕
              </button>
            </div>

            <p className="text-sm text-slate-300 mb-4">
              Enter the 6-digit Delivery OTP from the receiver to confirm arrival.
            </p>

            {otpMessage && (
              <div className="p-3 mb-4 rounded-lg bg-emerald-500/20 border border-emerald-500 text-emerald-300 text-sm font-semibold flex items-center gap-2">
                {otpMessage}
              </div>
            )}

            <div className="mb-5">
              <label className="block text-xs font-semibold text-amber-400 mb-1">
                Receiver 6-Digit OTP Code
              </label>
              <input
                type="text"
                placeholder="Enter OTP"
                value={otpInput}
                onChange={(e) => setOtpInput(e.target.value)}
                className="w-full bg-slate-800 border border-slate-700 rounded-xl px-4 py-3 text-center text-xl tracking-widest font-mono text-white focus:outline-none focus:border-amber-500"
              />
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => setShowOtpModal(false)}
                className="flex-1 py-3 bg-slate-800 hover:bg-slate-700 rounded-xl text-sm font-semibold transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleVerifyDelivery}
                disabled={verifyingOtp}
                className="flex-1 py-3 bg-[#C8933A] hover:bg-[#b07e2e] rounded-xl text-sm font-bold transition-colors cursor-pointer"
              >
                {verifyingOtp ? 'Verifying OTP…' : 'Verify & Unlock Escrow 🔓'}
              </button>
            </div>
          </div>
        </div>
      )}

      {delivery?.shipperId && (
        <ChatModal
          isOpen={chatOpen}
          onClose={() => setChatOpen(false)}
          receiverId={delivery.shipperId}
          receiverName={delivery.shipperName}
          loadTitle={`${delivery.origin} → ${delivery.destination}`}
        />
      )}
    </>
  );
}

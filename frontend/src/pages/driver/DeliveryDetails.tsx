import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import PageHeader from '../../components/PageHeader';
import StatusBadge from '../../components/StatusBadge';
import { get, post } from '../../services/api';

export default function DeliveryDetails() {
  const { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionMsg, setActionMsg] = useState<string | null>(null);
  const [pickupOtp, setPickupOtp] = useState('');
  const [deliveryOtp, setDeliveryOtp] = useState('');
  const [busy, setBusy] = useState(false);
  const [delivery, setDelivery] = useState<{
    id: string;
    origin: string;
    destination: string;
    status: string;
    cargoType: string;
    weight: number;
    shipper: string;
    vehicle: string;
  } | null>(null);

  const loadShipment = async () => {
    if (!id) {
      setError('Missing shipment id');
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      let raw: any;
      try {
        raw = await get<any>(`/shipments/${id}`);
      } catch {
        const list = await get<any>('/drivers/shipments');
        const rows = Array.isArray(list) ? list : list?.data ?? [];
        raw = rows.find((r: any) => String(r.id) === String(id)) ?? null;
      }
      const data = raw?.data ?? raw;
      if (!data) throw new Error('Shipment not found');
      setDelivery({
        id: String(data.id ?? id),
        origin: data.origin_city ?? '—',
        destination: data.destination_city ?? '—',
        status: String(data.status ?? 'ASSIGNED').toLowerCase(),
        cargoType: data.cargo_description ?? 'Freight',
        weight: Number(data.weight_tons ?? 0),
        shipper: data.shipper_name ?? 'Shipper',
        vehicle: data.vehicle_plate || data.vehicle_id || '—',
      });
    } catch (e: any) {
      setError(e?.message || 'Unable to load shipment');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let cancelled = false;
    (async () => {
      await loadShipment();
      if (cancelled) return;
    })();
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const handlePickupVerify = async () => {
    if (!delivery) return;
    if (!pickupOtp.trim()) {
      setActionMsg('Enter the pickup OTP from the shipper.');
      return;
    }
    setBusy(true);
    setActionMsg(null);
    try {
      await post(`/shipments/${delivery.id}/pickup-verify`, {
        pickup_otp: pickupOtp.trim(),
      });
      setActionMsg('Pickup verified — shipment is now in transit.');
      setPickupOtp('');
      await loadShipment();
    } catch (e: any) {
      setActionMsg(e?.message || 'Pickup verification failed');
    } finally {
      setBusy(false);
    }
  };

  const handleDeliveryVerify = async () => {
    if (!delivery) return;
    if (!deliveryOtp.trim()) {
      setActionMsg('Enter the delivery OTP from the receiver.');
      return;
    }
    setBusy(true);
    setActionMsg(null);
    try {
      await post(`/shipments/${delivery.id}/delivery-verify`, {
        delivery_otp: deliveryOtp.trim(),
      });
      setActionMsg('Delivery verified.');
      setDeliveryOtp('');
      await loadShipment();
    } catch (e: any) {
      setActionMsg(e?.message || 'Delivery verification failed');
    } finally {
      setBusy(false);
    }
  };

  if (loading) {
    return (
      <div>
        <PageHeader title="Delivery Details" subtitle="Loading…" />
      </div>
    );
  }

  if (error || !delivery) {
    return (
      <div>
        <PageHeader title="Delivery Details" subtitle={id ?? ''} />
        <p style={{ color: '#b91c1c' }}>{error || 'No shipment data'}</p>
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="Delivery Details" subtitle={`Delivery #${delivery.id.slice(0, 8)}`} />

      <div className="p2-detail-grid">
        <div className="p2-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
            <h3 style={{ fontFamily: 'Instrument Serif, serif' }}>Shipment</h3>
            <StatusBadge status={delivery.status} />
          </div>
          {[
            ['Route', `${delivery.origin} → ${delivery.destination}`],
            ['Cargo', delivery.cargoType],
            ['Weight', `${delivery.weight} tons`],
            ['Shipper', delivery.shipper],
            ['Vehicle', delivery.vehicle],
          ].map(([label, value]) => (
            <div key={label} className="p2-detail-row">
              <span className="p2-detail-label">{label}</span>
              <span className="p2-detail-value">{value}</span>
            </div>
          ))}
        </div>

        <div className="p2-card">
          <h3 style={{ fontFamily: 'Instrument Serif, serif', marginBottom: '1rem' }}>
            OTP Status Transitions
          </h3>
          <p style={{ color: '#6b7c8f', fontSize: '0.875rem', marginBottom: '1rem' }}>
            Status updates use <code>POST /shipments/:id/pickup-verify</code> and{' '}
            <code>delivery-verify</code> — there is no free-form status PATCH.
          </p>
          {actionMsg && (
            <p style={{ marginBottom: '1rem', color: actionMsg.toLowerCase().includes('fail') ? '#b91c1c' : '#047857' }}>
              {actionMsg}
            </p>
          )}
          <div className="p2-form-group">
            <label className="p2-form-label">Pickup OTP → In Transit</label>
            <input
              className="p2-input"
              value={pickupOtp}
              onChange={(e) => setPickupOtp(e.target.value)}
              placeholder="Pickup OTP"
            />
            <button
              type="button"
              className="btn-primary"
              style={{ marginTop: '0.75rem', width: '100%' }}
              disabled={busy}
              onClick={handlePickupVerify}
            >
              Verify Pickup
            </button>
          </div>
          <div className="p2-form-group" style={{ marginTop: '1.25rem' }}>
            <label className="p2-form-label">Delivery OTP → Delivered</label>
            <input
              className="p2-input"
              value={deliveryOtp}
              onChange={(e) => setDeliveryOtp(e.target.value)}
              placeholder="Delivery OTP"
            />
            <button
              type="button"
              className="btn-primary"
              style={{ marginTop: '0.75rem', width: '100%' }}
              disabled={busy}
              onClick={handleDeliveryVerify}
            >
              Verify Delivery
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

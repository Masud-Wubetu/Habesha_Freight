import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import PageHeader from '../../components/PageHeader';
import StatusBadge from '../../components/StatusBadge';
import { get, patch } from '../../services/api';

export default function DeliveryDetails() {
  const { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [status, setStatus] = useState('ASSIGNED');
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

  useEffect(() => {
    let cancelled = false;
    (async () => {
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
        if (cancelled) return;
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
        setStatus(String(data.status ?? 'ASSIGNED').toLowerCase());
      } catch (e: any) {
        if (!cancelled) setError(e?.message || 'Unable to load shipment');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [id]);

  const handleUpdateStatus = async () => {
    if (!delivery) return;
    try {
      await patch(`/shipments/${delivery.id}/status`, { status: status.toUpperCase() });
      setDelivery({ ...delivery, status });
    } catch (e: any) {
      alert(e?.message || 'Status update failed');
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
            Update Status
          </h3>
          <select
            className="p2-select"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
          >
            <option value="assigned">Assigned</option>
            <option value="in_transit">In Transit</option>
            <option value="delivered">Delivered</option>
          </select>
          <button
            type="button"
            className="btn-primary"
            style={{ marginTop: '1rem', width: '100%' }}
            onClick={handleUpdateStatus}
          >
            Update Status
          </button>
        </div>
      </div>
    </div>
  );
}

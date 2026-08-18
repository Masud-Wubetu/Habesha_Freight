import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface DeliveryRecord {
  id: string;
  shipper_name: string;
  driver_name: string;
  origin: string;
  destination: string;
  status: 'In Transit' | 'Bidding' | 'Delivered' | 'Assigned';
  amount: number;
  cargo_type?: string;
  weight?: string;
}

export default function AdminDeliveries() {
  const [loading, setLoading] = useState(false);
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [selectedDeliveryModal, setSelectedDeliveryModal] = useState<DeliveryRecord | null>(null);

  const defaultDeliveries: DeliveryRecord[] = [
    {
      id: 'SHP-001',
      shipper_name: 'Sara Bekele',
      driver_name: 'Abebe Girma',
      origin: 'Addis',
      destination: 'Dire Dawa',
      status: 'In Transit',
      amount: 8500,
      cargo_type: 'Agricultural Goods',
      weight: '12 Tons',
    },
    {
      id: 'SHP-002',
      shipper_name: 'Yohannes Alemu',
      driver_name: '—',
      origin: 'Adama',
      destination: 'Hawassa',
      status: 'Bidding',
      amount: 9200,
      cargo_type: 'Construction Materials',
      weight: '18 Tons',
    },
    {
      id: 'SHP-003',
      shipper_name: 'Sara Bekele',
      driver_name: 'Tesfaye Haile',
      origin: 'Addis',
      destination: 'Bahir Dar',
      status: 'Delivered',
      amount: 11000,
      cargo_type: 'Consumer Electronics',
      weight: '8 Tons',
    },
    {
      id: 'SHP-004',
      shipper_name: 'Tigist Worku',
      driver_name: 'Dawit Bekele',
      origin: 'Mekelle',
      destination: 'Addis',
      status: 'Assigned',
      amount: 14200,
      cargo_type: 'Textile Products',
      weight: '15 Tons',
    },
  ];

  const [deliveries, setDeliveries] = useState<DeliveryRecord[]>(defaultDeliveries);

  useEffect(() => {
    fetchDeliveries(statusFilter);
  }, [statusFilter]);

  const fetchDeliveries = async (filter: string) => {
    try {
      setLoading(true);
      const queryParam = filter !== 'ALL' ? `?status=${encodeURIComponent(filter)}` : '';
      const res = await api.get<{
        success: boolean;
        data?: { deliveries?: Record<string, unknown>[]; shipments?: Record<string, unknown>[] };
      }>(`/admin/deliveries${queryParam}`, true);

      const items = res?.data?.deliveries || res?.data?.shipments;

      if (res && res.success && items && items.length > 0) {
        const fetched: DeliveryRecord[] = items.map((d, index) => {
          const rawStatus = (d.status as string) || 'IN_TRANSIT';
          let formattedStatus: 'In Transit' | 'Bidding' | 'Delivered' | 'Assigned' = 'In Transit';
          if (rawStatus.toUpperCase().includes('BID')) formattedStatus = 'Bidding';
          if (rawStatus.toUpperCase().includes('DELIVERED') || rawStatus.toUpperCase().includes('COMPLETE')) formattedStatus = 'Delivered';
          if (rawStatus.toUpperCase().includes('ASSIGN')) formattedStatus = 'Assigned';

          return {
            id: (d.id as string) || (d.shipment_number as string) || `SHP-00${index + 1}`,
            shipper_name: (d.shipper_name as string) || (d.shipper as string) || 'Shipper Name',
            driver_name: (d.driver_name as string) || (d.driver as string) || '—',
            origin: (d.origin as string) || (d.pickup_city as string) || 'Addis',
            destination: (d.destination as string) || (d.dropoff_city as string) || 'Dire Dawa',
            status: formattedStatus,
            amount: Number(d.amount ?? d.price ?? 8500),
            cargo_type: (d.cargo_type as string) || 'General Cargo',
            weight: d.weight ? `${d.weight} Tons` : '10 Tons',
          };
        });
        setDeliveries(fetched);
      } else {
        if (filter !== 'ALL') {
          setDeliveries(defaultDeliveries.filter((d) => d.status.toUpperCase().replace(' ', '_') === filter.toUpperCase().replace(' ', '_')));
        } else {
          setDeliveries(defaultDeliveries);
        }
      }
    } catch {
      if (filter !== 'ALL') {
        setDeliveries(defaultDeliveries.filter((d) => d.status.toUpperCase().replace(' ', '_') === filter.toUpperCase().replace(' ', '_')));
      } else {
        setDeliveries(defaultDeliveries);
      }
    } finally {
      setLoading(false);
    }
  };

  const formattedDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  const getStatusBadgeStyle = (status: string) => {
    switch (status) {
      case 'In Transit':
        return { backgroundColor: '#E0F2FE', color: '#0284C7' };
      case 'Bidding':
        return { backgroundColor: '#FEF3C7', color: '#D97706' };
      case 'Delivered':
        return { backgroundColor: '#DCFCE7', color: '#16A34A' };
      case 'Assigned':
        return { backgroundColor: '#F3E8FF', color: '#9333EA' };
      default:
        return { backgroundColor: '#F3F4F6', color: '#4B5563' };
    }
  };

  return (
    <AdminLayout>
      <div style={{ padding: '2rem 2.5rem' }}>
        {/* Top Header Bar */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Deliveries</h1>
            <div style={{ fontSize: '0.875rem', color: '#64748B', marginTop: '0.25rem' }}>{formattedDate}</div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            {/* Open Disputes Alert Pill */}
            <Link
              to="/admin/disputes"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                backgroundColor: '#FEE2E2',
                color: '#DC2626',
                padding: '0.4rem 0.9rem',
                borderRadius: '2rem',
                fontSize: '0.85rem',
                fontWeight: 600,
                textDecoration: 'none',
              }}
            >
              <span>⚠️</span>
              <span>2 open disputes</span>
            </Link>

            {/* Dark Mode Toggle */}
            <button
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                backgroundColor: '#F1F5F9',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '1rem',
              }}
              title="Toggle Theme"
            >
              🌙
            </button>

            {/* Profile Avatar */}
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.85rem',
              }}
            >
              AD
            </div>
          </div>
        </div>

        {/* All Shipments Container Card */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            borderRadius: '0.85rem',
            padding: '1.75rem 2rem',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            border: '1px solid #E2E8F0',
          }}
        >
          {/* Card Header & Status Filter Dropdown */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.75rem' }}>
            <h2 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>All Shipments</h2>

            <div>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                style={{
                  padding: '0.5rem 1rem',
                  borderRadius: '0.5rem',
                  border: '1px solid #E2E8F0',
                  fontSize: '0.875rem',
                  color: '#0F172A',
                  backgroundColor: '#FFFFFF',
                  outline: 'none',
                  cursor: 'pointer',
                }}
              >
                <option value="ALL">All Statuses</option>
                <option value="IN_TRANSIT">In Transit</option>
                <option value="BIDDING">Bidding</option>
                <option value="DELIVERED">Delivered</option>
                <option value="ASSIGNED">Assigned</option>
              </select>
            </div>
          </div>

          {/* Table */}
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #E2E8F0', color: '#64748B', fontSize: '0.85rem', fontWeight: 600 }}>
                  <th style={{ padding: '0.75rem 1rem 0.75rem 0' }}>ID</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Shipper</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Driver</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Route</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Status</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Amount</th>
                  <th style={{ padding: '0.75rem 0 0.75rem 1rem' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={7} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      Loading shipments...
                    </td>
                  </tr>
                ) : deliveries.length === 0 ? (
                  <tr>
                    <td colSpan={7} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      No shipments found.
                    </td>
                  </tr>
                ) : (
                  deliveries.map((delivery) => (
                    <tr key={delivery.id} style={{ borderBottom: '1px solid #F1F5F9', fontSize: '0.9rem', color: '#0F172A' }}>
                      <td style={{ padding: '1rem 1rem 1rem 0', fontWeight: 700 }}>{delivery.id}</td>
                      <td style={{ padding: '1rem', fontWeight: 600, color: '#0F172A' }}>{delivery.shipper_name}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{delivery.driver_name}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>
                        {delivery.origin} → {delivery.destination}
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <span
                          style={{
                            padding: '0.25rem 0.75rem',
                            borderRadius: '1rem',
                            fontSize: '0.775rem',
                            fontWeight: 600,
                            ...getStatusBadgeStyle(delivery.status),
                          }}
                        >
                          {delivery.status}
                        </span>
                      </td>
                      <td style={{ padding: '1rem', fontWeight: 700, color: '#0F172A' }}>
                        ETB {delivery.amount.toLocaleString()}
                      </td>
                      <td style={{ padding: '1rem 0 1rem 1rem' }}>
                        <button
                          onClick={() => setSelectedDeliveryModal(delivery)}
                          style={{
                            background: 'none',
                            border: 'none',
                            color: '#2563EB',
                            fontWeight: 600,
                            fontSize: '0.85rem',
                            cursor: 'pointer',
                            padding: 0,
                          }}
                        >
                          Details
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Shipment Details Modal */}
      {selectedDeliveryModal && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0,0,0,0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
          }}
        >
          <div
            style={{
              backgroundColor: '#FFFFFF',
              borderRadius: '0.85rem',
              padding: '2rem',
              width: '460px',
              boxShadow: '0 10px 25px rgba(0,0,0,0.15)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, color: '#0F172A' }}>
                Shipment {selectedDeliveryModal.id}
              </h3>
              <button
                onClick={() => setSelectedDeliveryModal(null)}
                style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', color: '#64748B' }}
              >
                ✕
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', fontSize: '0.925rem' }}>
              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>ROUTE</span>
                <strong style={{ color: '#0F172A', fontSize: '1.05rem' }}>
                  {selectedDeliveryModal.origin} → {selectedDeliveryModal.destination}
                </strong>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>SHIPPER</span>
                <span style={{ color: '#0F172A' }}>{selectedDeliveryModal.shipper_name}</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>ASSIGNED DRIVER</span>
                <span style={{ color: '#0F172A' }}>{selectedDeliveryModal.driver_name}</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>CARGO DETAILS</span>
                <span style={{ color: '#0F172A' }}>
                  {selectedDeliveryModal.cargo_type} ({selectedDeliveryModal.weight})
                </span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>TOTAL AMOUNT</span>
                <strong style={{ color: '#16A34A', fontSize: '1.1rem' }}>
                  ETB {selectedDeliveryModal.amount.toLocaleString()}
                </strong>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>STATUS</span>
                <span
                  style={{
                    display: 'inline-block',
                    padding: '0.2rem 0.65rem',
                    borderRadius: '1rem',
                    fontSize: '0.75rem',
                    fontWeight: 600,
                    marginTop: '0.2rem',
                    ...getStatusBadgeStyle(selectedDeliveryModal.status),
                  }}
                >
                  {selectedDeliveryModal.status}
                </span>
              </div>
            </div>

            <div style={{ marginTop: '2rem', display: 'flex', justifyContent: 'flex-end' }}>
              <button
                onClick={() => setSelectedDeliveryModal(null)}
                style={{
                  backgroundColor: '#0F172A',
                  color: '#FFFFFF',
                  padding: '0.6rem 1.25rem',
                  borderRadius: '0.5rem',
                  border: 'none',
                  fontSize: '0.875rem',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

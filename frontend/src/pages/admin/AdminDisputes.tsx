import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface DisputeItem {
  id: string;
  reason: string;
  status: 'Open' | 'Resolved' | 'Under Review';
  shipper_name: string;
  driver_name: string;
  shipment_id: string;
  date: string;
  details?: string;
  resolution?: string;
}

export default function AdminDisputes() {
  const [loading, setLoading] = useState(false);
  const [infoModalItem, setInfoModalItem] = useState<DisputeItem | null>(null);

  const defaultDisputes: DisputeItem[] = [
    {
      id: 'DIS-001',
      reason: 'Late Delivery',
      status: 'Open',
      shipper_name: 'Yohannes',
      driver_name: 'Dawit',
      shipment_id: 'SHP-002',
      date: 'Aug 8',
      details: 'The shipment arrived 6 hours past agreed schedule, causing warehouse unloading delay penalties.',
    },
    {
      id: 'DIS-002',
      reason: 'Cargo Damage',
      status: 'Resolved',
      shipper_name: 'Sara',
      driver_name: 'Tesfaye',
      shipment_id: 'SHP-005',
      date: 'Jul 30',
      details: 'Minor damage to 2 textile boxes during transit. Partial refund issued to shipper.',
      resolution: 'Resolved in Shipper Favor',
    },
  ];

  const [disputes, setDisputes] = useState<DisputeItem[]>(defaultDisputes);

  useEffect(() => {
    fetchDisputes();
  }, []);

  const fetchDisputes = async () => {
    try {
      setLoading(true);
      const res = await api.get<{
        success: boolean;
        data?: { disputes?: Record<string, unknown>[] };
      }>('/admin/disputes', true);

      if (res && res.success && res.data?.disputes && res.data.disputes.length > 0) {
        const fetched: DisputeItem[] = res.data.disputes.map((d, index) => {
          const rawStatus = (d.status as string) || 'OPEN';
          let formattedStatus: 'Open' | 'Resolved' | 'Under Review' = 'Open';
          if (rawStatus.toUpperCase() === 'RESOLVED' || rawStatus.toUpperCase() === 'CLOSED') formattedStatus = 'Resolved';
          if (rawStatus.toUpperCase().includes('REVIEW')) formattedStatus = 'Under Review';

          const formattedDate = d.created_at
            ? new Date(d.created_at as string).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
            : 'Aug 8';

          return {
            id: (d.id as string) || (d.dispute_number as string) || `DIS-00${index + 1}`,
            reason: (d.reason as string) || (d.issue_type as string) || 'Late Delivery',
            status: formattedStatus,
            shipper_name: (d.shipper_name as string) || (d.shipper as string) || 'Shipper',
            driver_name: (d.driver_name as string) || (d.driver as string) || 'Driver',
            shipment_id: (d.shipment_id as string) || (d.shipment_number as string) || `SHP-00${index + 1}`,
            date: formattedDate,
            details: (d.description as string) || (d.details as string) || 'Dispute case open for administrative review.',
            resolution: d.resolution as string,
          };
        });
        setDisputes(fetched);
      }
    } catch (err) {
      console.warn('Backend API note: loading local dispute cases', err);
    } finally {
      setLoading(false);
    }
  };

  const handleResolve = async (dispute: DisputeItem, favor: 'Shipper' | 'Driver') => {
    // Optimistic UI state update
    setDisputes((prev) =>
      prev.map((d) => {
        if (d.id === dispute.id) {
          return {
            ...d,
            status: 'Resolved',
            resolution: `Resolved in ${favor}'s Favor`,
          };
        }
        return d;
      })
    );

    try {
      await api.post(
        `/admin/disputes/${dispute.id}/resolve`,
        { favor: favor.toUpperCase(), resolution: `Resolved in ${favor}'s Favor` },
        true
      );
    } catch (err) {
      console.warn(`Dispute resolved in UI state for ${dispute.id}`, err);
    }
  };

  const formattedDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  const openDisputesCount = disputes.filter((d) => d.status === 'Open').length;

  return (
    <AdminLayout>
      <div style={{ padding: '2rem 2.5rem' }}>
        {/* Top Header Bar */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Disputes</h1>
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
              <span>{openDisputesCount} open disputes</span>
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

        {/* Stacked Dispute Cards */}
        {loading ? (
          <div
            style={{
              backgroundColor: '#FFFFFF',
              borderRadius: '0.85rem',
              padding: '3rem',
              textAlign: 'center',
              color: '#64748B',
            }}
          >
            Loading disputes...
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            {disputes.map((dispute) => (
              <div
                key={dispute.id}
                style={{
                  backgroundColor: '#FFFFFF',
                  borderRadius: '0.85rem',
                  padding: '1.75rem 2rem',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
                  border: dispute.status === 'Open' ? '1px solid #FCA5A5' : '1px solid #E2E8F0',
                }}
              >
                {/* Header Title Row & Status Pill */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.4rem' }}>
                  <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>
                    {dispute.id} · {dispute.reason}
                  </h3>
                  <span
                    style={{
                      backgroundColor: dispute.status === 'Open' ? '#FEE2E2' : '#F1F5F9',
                      color: dispute.status === 'Open' ? '#DC2626' : '#64748B',
                      padding: '0.2rem 0.65rem',
                      borderRadius: '1rem',
                      fontSize: '0.75rem',
                      fontWeight: 600,
                    }}
                  >
                    {dispute.status}
                  </span>
                </div>

                {/* Subtitle & Date Information */}
                <div style={{ fontSize: '0.875rem', color: '#64748B', marginBottom: '0.25rem' }}>
                  {dispute.shipper_name} vs {dispute.driver_name} · {dispute.shipment_id}
                </div>
                <div style={{ fontSize: '0.8rem', color: '#94A3B8', marginBottom: dispute.status === 'Open' ? '1.5rem' : 0 }}>
                  {dispute.date}
                </div>

                {/* Resolution Summary (If Resolved) */}
                {dispute.status === 'Resolved' && dispute.resolution && (
                  <div
                    style={{
                      marginTop: '0.75rem',
                      fontSize: '0.85rem',
                      fontWeight: 600,
                      color: '#16A34A',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.35rem',
                    }}
                  >
                    <span>✓</span>
                    <span>{dispute.resolution}</span>
                  </div>
                )}

                {/* Action Buttons Row (For Open Disputes) */}
                {dispute.status === 'Open' && (
                  <div style={{ display: 'flex', gap: '0.85rem', flexWrap: 'wrap' }}>
                    <button
                      onClick={() => handleResolve(dispute, 'Shipper')}
                      style={{
                        backgroundColor: '#00A651',
                        color: '#FFFFFF',
                        border: 'none',
                        borderRadius: '0.5rem',
                        padding: '0.7rem 1.4rem',
                        fontSize: '0.875rem',
                        fontWeight: 700,
                        cursor: 'pointer',
                        transition: 'background-color 0.2s',
                      }}
                    >
                      Resolve in Shipper's Favor
                    </button>

                    <button
                      onClick={() => handleResolve(dispute, 'Driver')}
                      style={{
                        backgroundColor: '#2563EB',
                        color: '#FFFFFF',
                        border: 'none',
                        borderRadius: '0.5rem',
                        padding: '0.7rem 1.4rem',
                        fontSize: '0.875rem',
                        fontWeight: 700,
                        cursor: 'pointer',
                        transition: 'background-color 0.2s',
                      }}
                    >
                      Resolve in Driver's Favor
                    </button>

                    <button
                      onClick={() => setInfoModalItem(dispute)}
                      style={{
                        backgroundColor: '#FFFFFF',
                        color: '#475569',
                        border: '1px solid #CBD5E1',
                        borderRadius: '0.5rem',
                        padding: '0.7rem 1.4rem',
                        fontSize: '0.875rem',
                        fontWeight: 600,
                        cursor: 'pointer',
                        transition: 'background-color 0.2s',
                      }}
                    >
                      Request More Info
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Dispute Details & Request Info Modal */}
      {infoModalItem && (
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
              width: '480px',
              boxShadow: '0 10px 25px rgba(0,0,0,0.15)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, color: '#0F172A' }}>
                Dispute Case {infoModalItem.id}
              </h3>
              <button
                onClick={() => setInfoModalItem(null)}
                style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', color: '#64748B' }}
              >
                ✕
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', fontSize: '0.925rem' }}>
              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>ISSUE TYPE</span>
                <strong style={{ color: '#0F172A', fontSize: '1.05rem' }}>{infoModalItem.reason}</strong>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>PARTIES INVOLVED</span>
                <span style={{ color: '#0F172A' }}>
                  Shipper: {infoModalItem.shipper_name} vs Driver: {infoModalItem.driver_name}
                </span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>ASSOCIATED SHIPMENT</span>
                <span style={{ color: '#0F172A' }}>{infoModalItem.shipment_id}</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>CASE DETAILS</span>
                <p style={{ color: '#334155', backgroundColor: '#F8FAFC', padding: '0.75rem', borderRadius: '0.5rem', margin: '0.25rem 0 0 0', border: '1px solid #E2E8F0' }}>
                  {infoModalItem.details}
                </p>
              </div>
            </div>

            <div style={{ marginTop: '2rem', display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button
                onClick={() => setInfoModalItem(null)}
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

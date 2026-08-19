import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface VerificationItem {
  id: string;
  applicant_name: string;
  document_type: string;
  reference_number: string;
  submitted_date: string;
  file_name: string;
  file_url?: string;
  status: 'Pending Review' | 'Approved' | 'Rejected';
}

export default function AdminVerification() {
  const [loading, setLoading] = useState(false);
  const [previewFileModal, setPreviewFileModal] = useState<VerificationItem | null>(null);

  const defaultVerificationQueue: VerificationItem[] = [
    {
      id: 'KYC-001',
      applicant_name: 'Selam Tadesse',
      document_type: 'Driver License',
      reference_number: 'DRV-00789',
      submitted_date: 'Submitted Aug 11',
      file_name: 'drivers_license.jpg',
      status: 'Pending Review',
    },
    {
      id: 'KYC-002',
      applicant_name: 'Kibru Alemu',
      document_type: 'Fayda ID',
      reference_number: 'USR-01012',
      submitted_date: 'Submitted Aug 12',
      file_name: 'fayda_id.jpg',
      status: 'Pending Review',
    },
    {
      id: 'KYC-003',
      applicant_name: 'Horn Logistics PLC',
      document_type: 'Company Registration',
      reference_number: 'CMP-00031',
      submitted_date: 'Submitted Aug 10',
      file_name: 'business_reg.pdf',
      status: 'Pending Review',
    },
  ];

  const [queue, setQueue] = useState<VerificationItem[]>(defaultVerificationQueue);

  useEffect(() => {
    fetchKYCQueue();
  }, []);

  const fetchKYCQueue = async () => {
    try {
      setLoading(true);
      const res = await api.get<{
        success: boolean;
        data?: { queue?: Record<string, unknown>[]; pending?: Record<string, unknown>[] };
      }>('/admin/kyc', true);

      const items = res?.data?.queue || res?.data?.pending;

      if (res && res.success && items && items.length > 0) {
        const fetchedQueue: VerificationItem[] = items.map((item, index) => {
          const rawStatus = (item.status as string) || 'PENDING';
          let formattedStatus: 'Pending Review' | 'Approved' | 'Rejected' = 'Pending Review';
          if (rawStatus.toUpperCase() === 'APPROVED' || rawStatus.toUpperCase() === 'VERIFIED') formattedStatus = 'Approved';
          if (rawStatus.toUpperCase() === 'REJECTED') formattedStatus = 'Rejected';

          const submitted = item.created_at
            ? `Submitted ${new Date(item.created_at as string).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`
            : 'Submitted Aug 11';

          return {
            id: (item.id as string) || `KYC-00${index + 1}`,
            applicant_name: (item.applicant_name as string) || (item.name as string) || (item.full_name as string) || 'Applicant Name',
            document_type: (item.document_type as string) || (item.type as string) || 'Driver License',
            reference_number: (item.reference_number as string) || (item.doc_id as string) || `DRV-00${index + 700}`,
            submitted_date: submitted,
            file_name: (item.file_name as string) || (item.document_url ? (item.document_url as string).split('/').pop()! : 'document.pdf'),
            file_url: item.document_url as string,
            status: formattedStatus,
          };
        });
        setQueue(fetchedQueue);
      }
    } catch (err) {
      console.warn('Backend API note: loading local verification queue data', err);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (item: VerificationItem) => {
    // Optimistic UI state update
    setQueue((prev) =>
      prev.map((q) => {
        if (q.id === item.id) {
          return { ...q, status: 'Approved' };
        }
        return q;
      })
    );

    try {
      await api.post(`/admin/kyc/${item.id}/verify`, { status: 'APPROVED' }, true);
    } catch (err) {
      console.warn(`Verification approved in UI state for ${item.id}`, err);
    }
  };

  const handleReject = async (item: VerificationItem) => {
    // Optimistic UI state update
    setQueue((prev) =>
      prev.map((q) => {
        if (q.id === item.id) {
          return { ...q, status: 'Rejected' };
        }
        return q;
      })
    );

    try {
      await api.post(`/admin/kyc/${item.id}/reject`, { reason: 'Document verification failed requirements' }, true);
    } catch (err) {
      console.warn(`Verification rejected in UI state for ${item.id}`, err);
    }
  };

  const formattedDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  return (
    <AdminLayout>
      <div style={{ padding: '2rem 2.5rem' }}>
        {/* Top Header Bar */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Verification</h1>
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

        {/* Verification Queue Stacked Cards */}
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
            Loading verification requests...
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            {queue.map((item) => (
              <div
                key={item.id}
                style={{
                  backgroundColor: '#FFFFFF',
                  borderRadius: '0.85rem',
                  padding: '1.75rem 2rem',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
                  border: '1px solid #E2E8F0',
                }}
              >
                {/* Title Row & Status Pill */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.35rem' }}>
                  <h3 style={{ fontSize: '1.15rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>
                    {item.applicant_name}
                  </h3>
                  <span
                    style={{
                      backgroundColor:
                        item.status === 'Approved' ? '#DCFCE7' : item.status === 'Rejected' ? '#FEE2E2' : '#FEF3C7',
                      color:
                        item.status === 'Approved' ? '#15803D' : item.status === 'Rejected' ? '#B91C1C' : '#B45309',
                      padding: '0.2rem 0.65rem',
                      borderRadius: '1rem',
                      fontSize: '0.75rem',
                      fontWeight: 600,
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '0.25rem',
                    }}
                  >
                    {item.status === 'Pending Review' ? '⏳ Pending Review' : item.status}
                  </span>
                </div>

                {/* Subtitle Information */}
                <div style={{ fontSize: '0.875rem', color: '#64748B', marginBottom: '1.25rem' }}>
                  {item.document_type} · {item.reference_number} · {item.submitted_date}
                </div>

                {/* Attachment Box Container */}
                <div
                  style={{
                    backgroundColor: '#F8FAFC',
                    border: '1px solid #E2E8F0',
                    borderRadius: '0.6rem',
                    padding: '0.85rem 1.25rem',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginBottom: '1.25rem',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', color: '#334155', fontSize: '0.9rem' }}>
                    <span style={{ fontSize: '1.1rem', color: '#64748B' }}>📄</span>
                    <span style={{ fontWeight: 500 }}>{item.file_name}</span>
                  </div>

                  <button
                    onClick={() => setPreviewFileModal(item)}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: '#2563EB',
                      fontWeight: 600,
                      fontSize: '0.875rem',
                      cursor: 'pointer',
                    }}
                  >
                    Preview
                  </button>
                </div>

                {/* Action Buttons Row */}
                <div style={{ display: 'flex', gap: '1rem' }}>
                  <button
                    onClick={() => handleApprove(item)}
                    disabled={item.status === 'Approved'}
                    style={{
                      flex: 1,
                      backgroundColor: item.status === 'Approved' ? '#86EFAC' : '#00A651',
                      color: '#FFFFFF',
                      border: 'none',
                      borderRadius: '0.5rem',
                      padding: '0.75rem',
                      fontSize: '0.925rem',
                      fontWeight: 700,
                      cursor: item.status === 'Approved' ? 'default' : 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '0.5rem',
                      transition: 'background-color 0.2s',
                    }}
                  >
                    <span>✓</span>
                    <span>{item.status === 'Approved' ? 'Approved' : 'Approve'}</span>
                  </button>

                  <button
                    onClick={() => handleReject(item)}
                    disabled={item.status === 'Rejected'}
                    style={{
                      flex: 1,
                      backgroundColor: '#FFFFFF',
                      color: item.status === 'Rejected' ? '#9CA3AF' : '#DC2626',
                      border: `1px solid ${item.status === 'Rejected' ? '#E5E7EB' : '#FEE2E2'}`,
                      borderRadius: '0.5rem',
                      padding: '0.75rem',
                      fontSize: '0.925rem',
                      fontWeight: 700,
                      cursor: item.status === 'Rejected' ? 'default' : 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '0.5rem',
                      transition: 'background-color 0.2s',
                    }}
                  >
                    <span>✕</span>
                    <span>{item.status === 'Rejected' ? 'Rejected' : 'Reject'}</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Document Preview Modal */}
      {previewFileModal && (
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
              width: '500px',
              boxShadow: '0 10px 25px rgba(0,0,0,0.15)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, color: '#0F172A' }}>
                Document Preview
              </h3>
              <button
                onClick={() => setPreviewFileModal(null)}
                style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', color: '#64748B' }}
              >
                ✕
              </button>
            </div>

            <div
              style={{
                backgroundColor: '#F8FAFC',
                border: '1px border #E2E8F0',
                borderRadius: '0.5rem',
                padding: '2rem',
                textAlign: 'center',
                marginBottom: '1.5rem',
              }}
            >
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>📄</div>
              <strong style={{ color: '#0F172A', display: 'block', fontSize: '1.1rem', marginBottom: '0.25rem' }}>
                {previewFileModal.file_name}
              </strong>
              <span style={{ color: '#64748B', fontSize: '0.875rem' }}>
                {previewFileModal.document_type} for {previewFileModal.applicant_name}
              </span>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button
                onClick={() => setPreviewFileModal(null)}
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

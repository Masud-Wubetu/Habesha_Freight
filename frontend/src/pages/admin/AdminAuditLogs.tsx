import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface AuditLogItem {
  id: string;
  action: string;
  target: string;
  actor: string;
  timestamp: string;
}

export default function AdminAuditLogs() {
  const [loading, setLoading] = useState(false);

  const defaultLogs: AuditLogItem[] = [
    {
      id: 'LOG-001',
      action: 'User suspended',
      target: 'Tesfaye Haile',
      actor: 'Admin',
      timestamp: 'Aug 9, 09:14',
    },
    {
      id: 'LOG-002',
      action: 'Shipment created',
      target: 'SHP-001',
      actor: 'Sara Bekele',
      timestamp: 'Aug 7, 08:00',
    },
    {
      id: 'LOG-003',
      action: 'Bid accepted',
      target: 'BID-0041',
      actor: 'Sara Bekele',
      timestamp: 'Aug 7, 09:32',
    },
    {
      id: 'LOG-004',
      action: 'Escrow released',
      target: 'ESC-002',
      actor: 'System',
      timestamp: 'Aug 5, 17:20',
    },
    {
      id: 'LOG-005',
      action: 'Driver verified',
      target: 'Abebe Girma',
      actor: 'Admin',
      timestamp: 'Aug 1, 11:05',
    },
  ];

  const [logs, setLogs] = useState<AuditLogItem[]>(defaultLogs);

  useEffect(() => {
    fetchAuditLogs();
  }, []);

  const fetchAuditLogs = async () => {
    try {
      setLoading(true);
      const res = await api.get<{
        success: boolean;
        data?: { logs?: Record<string, unknown>[]; auditLogs?: Record<string, unknown>[] };
      }>('/admin/audit-logs', true);

      if (res && res.success) {
        const rawItems = res.data?.logs || res.data?.auditLogs;
        if (rawItems && rawItems.length > 0) {
          const fetched: AuditLogItem[] = rawItems.map((item, index) => {
            const rawTime = item.created_at || item.timestamp;
            const formattedTime = rawTime
              ? new Date(rawTime as string).toLocaleDateString('en-US', {
                  month: 'short',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                })
              : 'Aug 9, 09:14';

            return {
              id: (item.id as string) || `LOG-00${index + 1}`,
              action: (item.action as string) || (item.event as string) || 'System Activity',
              target: (item.target as string) || (item.entity_name as string) || (item.resource as string) || 'System',
              actor: (item.actor as string) || (item.user_name as string) || (item.created_by as string) || 'Admin',
              timestamp: formattedTime,
            };
          });
          setLogs(fetched);
        }
      }
    } catch (err) {
      console.warn('Backend API note: loading local audit log history records', err);
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

  return (
    <AdminLayout>
      <div style={{ padding: '2rem 2.5rem' }}>
        {/* Top Header Bar */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Audit Logs</h1>
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

        {/* Audit Logs Card Container */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            borderRadius: '0.85rem',
            padding: '1.75rem 2rem',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            border: '1px solid #E2E8F0',
          }}
        >
          {/* Card Header */}
          <div style={{ marginBottom: '1.5rem' }}>
            <h2 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Audit Logs</h2>
          </div>

          {/* Audit Logs Rows */}
          {loading ? (
            <div style={{ padding: '2.5rem', textAlign: 'center', color: '#64748B' }}>
              Loading audit logs...
            </div>
          ) : logs.length === 0 ? (
            <div style={{ padding: '2.5rem', textAlign: 'center', color: '#64748B' }}>
              No audit log activity recorded.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {logs.map((log, index) => (
                <div
                  key={log.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '1.1rem 0.5rem',
                    borderBottom: index < logs.length - 1 ? '1px solid #F1F5F9' : 'none',
                  }}
                >
                  {/* Left Icon & Action Text */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div
                      style={{
                        width: '42px',
                        height: '42px',
                        borderRadius: '0.65rem',
                        backgroundColor: '#FFFBEB',
                        border: '1px solid #FDE68A',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '1.1rem',
                        flexShrink: 0,
                      }}
                    >
                      📋
                    </div>

                    <div>
                      <span style={{ fontSize: '0.925rem', fontWeight: 700, color: '#1E293B' }}>
                        {log.action}
                      </span>
                      <span style={{ fontSize: '0.925rem', color: '#64748B', margin: '0 0.4rem' }}>
                        →
                      </span>
                      <span style={{ fontSize: '0.925rem', fontWeight: 500, color: '#475569' }}>
                        {log.target}
                      </span>
                    </div>
                  </div>

                  {/* Right Side Actor & Timestamp */}
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontSize: '0.85rem', fontWeight: 500, color: '#64748B' }}>
                      {log.actor}
                    </div>
                    <div style={{ fontSize: '0.8rem', color: '#94A3B8', marginTop: '0.15rem' }}>
                      {log.timestamp}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}

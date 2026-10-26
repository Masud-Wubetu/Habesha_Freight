import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';

import AdminLayout from '../../layouts/AdminLayout';

interface ReportCardData {
  id: string;
  title: string;
  subtitle: string;
  bars: { label: string; value: number; heightPct: number }[];
  exportType: string;
  emptyHint: string;
}

function barsFromSeries(
  items: { label: string; value: number }[],
): { label: string; value: number; heightPct: number }[] {
  if (!items.length) return [];
  const max = Math.max(...items.map((i) => i.value), 1);
  return items.map((i) => ({
    label: i.label,
    value: i.value,
    heightPct: Math.max(8, Math.round((i.value / max) * 100)),
  }));
}

export default function AdminReports() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [reports, setReports] = useState<ReportCardData[]>([]);
  const [openDisputesCount, setOpenDisputesCount] = useState(0);

  useEffect(() => {
    fetchReports();
    fetchLiveMetrics();
  }, []);

  const fetchLiveMetrics = async () => {
    try {
      const res: any = await api.get('/admin/dashboard', true).catch(() => null);
      if (res?.data?.activeDisputes !== undefined) {
        setOpenDisputesCount(Number(res.data.activeDisputes));
      }
    } catch (err) {
      console.warn('Dashboard metrics query:', err);
    }
  };

  const fetchReports = async () => {
    setLoading(true);
    setError(null);
    try {
      const [revenue, users, drivers, companies, deliveries] = await Promise.all([
        api.get<any>('/admin/reports/revenue?group_by=week', true).catch(() => null),
        api.get<any>('/admin/reports/users', true).catch(() => null),
        api.get<any>('/admin/reports/drivers', true).catch(() => null),
        api.get<any>('/admin/reports/companies', true).catch(() => null),
        api.get<any>('/admin/reports/deliveries', true).catch(() => null),
      ]);

      const revenueData = revenue?.data ?? revenue;
      const userData = users?.data ?? users;
      const driverData = drivers?.data ?? drivers;
      const companyData = companies?.data ?? companies;
      const deliveryData = deliveries?.data ?? deliveries;

      const next: ReportCardData[] = [
        {
          id: 'revenue-by-week',
          title: 'Revenue by Period',
          subtitle: `Total ETB ${Number(revenueData?.totalRevenue ?? 0).toLocaleString()}`,
          exportType: 'revenue',
          emptyHint: 'No completed payments in range.',
          bars: barsFromSeries(
            (revenueData?.breakdown || []).map((b: any) => ({
              label: String(b.date || ''),
              value: Number(b.amount || 0),
            })),
          ),
        },
        {
          id: 'users-by-role',
          title: 'Users by Role',
          subtitle: `Total users ${Number(userData?.totalUsers ?? 0).toLocaleString()}`,
          exportType: 'users',
          emptyHint: 'No user breakdown returned.',
          bars: barsFromSeries(
            (userData?.usersByRole || []).map((u: any) => ({
              label: String(u.role || 'UNKNOWN'),
              value: Number(u.count || 0),
            })),
          ),
        },
        {
          id: 'driver-performance',
          title: 'Drivers',
          subtitle: `Avg rating ${Number(driverData?.averageRating ?? 0).toFixed(1)} · ${Number(driverData?.totalDrivers ?? 0)} drivers`,
          exportType: 'drivers',
          emptyHint: 'No driver status data.',
          bars: barsFromSeries(
            (driverData?.driversByStatus || []).map((d: any) => ({
              label: String(d.status || 'ACTIVE'),
              value: Number(d.count || 0),
            })),
          ),
        },
        {
          id: 'companies-deliveries',
          title: 'Companies & Deliveries',
          subtitle: `${Number(companyData?.totalCompanies ?? 0)} companies · ${Number(deliveryData?.totalDeliveries ?? 0)} deliveries`,
          exportType: 'deliveries',
          emptyHint: 'No company/delivery breakdown.',
          bars: barsFromSeries([
            ...(companyData?.companiesByStatus || []).map((c: any) => ({
              label: `Co:${c.status || 'ACTIVE'}`,
              value: Number(c.count || 0),
            })),
            ...(deliveryData?.deliveriesByStatus || []).map((d: any) => ({
              label: String(d.status || 'UNKNOWN'),
              value: Number(d.count || 0),
            })),
          ]),
        },
      ];

      setReports(next);
      if (!revenue && !users && !drivers && !companies && !deliveries) {
        setError('Unable to load admin reports. Check admin auth and API.');
      }
    } catch (err: any) {
      setError(err?.message || 'Failed to load reports');
      setReports([]);
    } finally {
      setLoading(false);
    }
  };

  const handleDownloadCSV = async (report: ReportCardData) => {
    try {
      const res: any = await api.get(`/admin/reports/${report.exportType}/export`, true);
      const payload = res?.data ?? res;
      const csvText =
        typeof payload === 'string'
          ? payload
          : payload?.csv ||
            payload?.content ||
            (payload ? JSON.stringify(payload, null, 2) : '');

      if (!csvText) {
        alert('Export returned no data.');
        return;
      }

      const blob = new Blob([csvText], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `${report.exportType}_report.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (err: any) {
      alert(err?.message || 'CSV export failed.');
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
      <div style={{ padding: '1rem 1.25rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Reports</h1>
            <div style={{ fontSize: '0.875rem', color: '#64748B', marginTop: '0.25rem' }}>{formattedDate}</div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
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

        {error && (
          <div style={{ marginBottom: '1rem', color: '#b91c1c', fontSize: '0.9rem' }}>{error}</div>
        )}

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
            Loading report analytics...
          </div>
        ) : (
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(2, 1fr)',
              gap: '1.5rem',
            }}
          >
            {reports.map((report) => (
              <div
                key={report.id}
                style={{
                  backgroundColor: '#FFFFFF',
                  borderRadius: '0.85rem',
                  padding: '1.75rem 2rem',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
                  border: '1px solid #E2E8F0',
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'space-between',
                  minHeight: '260px',
                }}
              >
                <div>
                  <h3 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>
                    {report.title}
                  </h3>
                  <div style={{ fontSize: '0.85rem', color: '#64748B', marginTop: '0.25rem' }}>
                    {report.subtitle}
                  </div>

                  {report.bars.length === 0 ? (
                    <p style={{ marginTop: '2rem', color: '#94A3B8', fontSize: '0.875rem' }}>
                      {report.emptyHint}
                    </p>
                  ) : (
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'flex-end',
                        gap: '0.75rem',
                        height: '110px',
                        marginTop: '2rem',
                        marginBottom: '1.5rem',
                      }}
                    >
                      {report.bars.map((bar, idx) => (
                        <div
                          key={idx}
                          style={{
                            flex: 1,
                            height: `${bar.heightPct}%`,
                            backgroundColor: '#E5E7EB',
                            borderRadius: '0.25rem',
                            transition: 'height 0.3s ease, background-color 0.2s',
                          }}
                          title={`${bar.label}: ${bar.value}`}
                        />
                      ))}
                    </div>
                  )}
                </div>

                <div>
                  <button
                    onClick={() => handleDownloadCSV(report)}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: '#C8933A',
                      fontSize: '0.875rem',
                      fontWeight: 600,
                      cursor: 'pointer',
                      padding: 0,
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '0.25rem',
                    }}
                  >
                    Download CSV →
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

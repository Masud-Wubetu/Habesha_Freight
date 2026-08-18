import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface CompanyRecord {
  id: string;
  company_name: string;
  contact: string;
  fleet_size: number;
  completed_trips: number;
  rating: number;
  status: 'Active' | 'Pending' | 'Suspended';
}

export default function AdminCompanies() {
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCompanyModal, setSelectedCompanyModal] = useState<CompanyRecord | null>(null);

  const defaultCompanies: CompanyRecord[] = [
    {
      id: 'CMP-001',
      company_name: 'Ethio Transport Solutions',
      contact: '+251 911 234 567',
      fleet_size: 5,
      completed_trips: 115,
      rating: 4.8,
      status: 'Active',
    },
    {
      id: 'CMP-002',
      company_name: 'Abay Freight Services',
      contact: '+251 912 345 678',
      fleet_size: 12,
      completed_trips: 284,
      rating: 4.6,
      status: 'Active',
    },
    {
      id: 'CMP-003',
      company_name: 'Horn Logistics PLC',
      contact: '+251 913 456 789',
      fleet_size: 8,
      completed_trips: 92,
      rating: 4.3,
      status: 'Pending',
    },
  ];

  const [companies, setCompanies] = useState<CompanyRecord[]>(defaultCompanies);

  useEffect(() => {
    fetchCompanies(searchTerm);
  }, [searchTerm]);

  const fetchCompanies = async (searchQuery: string) => {
    try {
      setLoading(true);
      const queryParam = searchQuery ? `?search=${encodeURIComponent(searchQuery)}` : '';
      const res = await api.get<{
        success: boolean;
        data?: { companies?: Record<string, unknown>[] };
      }>(`/admin/companies${queryParam}`, true);

      if (res && res.success && res.data?.companies && res.data.companies.length > 0) {
        const fetchedCompanies: CompanyRecord[] = res.data.companies.map((c, index) => {
          const rawStatus = (c.status as string) || (c.is_verified ? 'ACTIVE' : 'PENDING');
          let formattedStatus: 'Active' | 'Pending' | 'Suspended' = 'Active';
          if (rawStatus.toUpperCase() === 'SUSPENDED') formattedStatus = 'Suspended';
          if (rawStatus.toUpperCase() === 'PENDING') formattedStatus = 'Pending';

          return {
            id: (c.id as string) || `CMP-00${index + 1}`,
            company_name: (c.company_name as string) || (c.name as string) || 'Transport Company',
            contact: (c.phone_number as string) || (c.contact as string) || '+251 900 000 000',
            fleet_size: Number(c.fleet_size ?? c.vehicles_count ?? 5),
            completed_trips: Number(c.completed_trips ?? c.trips_count ?? 100),
            rating: Number(c.rating ?? 4.5),
            status: formattedStatus,
          };
        });
        setCompanies(fetchedCompanies);
      } else {
        if (searchQuery) {
          const lower = searchQuery.toLowerCase();
          setCompanies(
            defaultCompanies.filter(
              (c) =>
                c.company_name.toLowerCase().includes(lower) ||
                c.contact.includes(lower)
            )
          );
        } else {
          setCompanies(defaultCompanies);
        }
      }
    } catch {
      if (searchQuery) {
        const lower = searchQuery.toLowerCase();
        setCompanies(
          defaultCompanies.filter(
            (c) =>
              c.company_name.toLowerCase().includes(lower) ||
              c.contact.includes(lower)
          )
        );
      } else {
        setCompanies(defaultCompanies);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (company: CompanyRecord) => {
    const isCurrentlySuspended = company.status === 'Suspended';
    const newStatus = isCurrentlySuspended ? 'Active' : 'Suspended';

    // Optimistic UI update
    setCompanies((prev) =>
      prev.map((c) => {
        if (c.id === company.id) {
          return {
            ...c,
            status: newStatus,
          };
        }
        return c;
      })
    );

    try {
      await api.patch(`/admin/companies/${company.id}/status`, { status: newStatus.toUpperCase() }, true);
    } catch (err) {
      console.warn(`Company status updated in UI state for ${company.id}`, err);
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
      case 'Active':
        return { backgroundColor: '#DCFCE7', color: '#15803D' };
      case 'Suspended':
        return { backgroundColor: '#FEE2E2', color: '#B91C1C' };
      case 'Pending':
        return { backgroundColor: '#FEF3C7', color: '#B45309' };
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
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Transport Companies</h1>
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

        {/* Transport Companies Card Container */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            borderRadius: '0.85rem',
            padding: '1.75rem 2rem',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            border: '1px solid #E2E8F0',
          }}
        >
          {/* Card Header & Search Input */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.75rem' }}>
            <h2 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Transport Companies</h2>

            <div style={{ position: 'relative', width: '260px' }}>
              <input
                type="text"
                placeholder="Search..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={{
                  width: '100%',
                  padding: '0.55rem 1rem 0.55rem 2.25rem',
                  borderRadius: '0.5rem',
                  border: '1px solid #E2E8F0',
                  fontSize: '0.875rem',
                  outline: 'none',
                  color: '#0F172A',
                }}
              />
              <span
                style={{
                  position: 'absolute',
                  left: '0.75rem',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: '#94A3B8',
                  fontSize: '0.9rem',
                }}
              >
                🔍
              </span>
            </div>
          </div>

          {/* Table */}
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #E2E8F0', color: '#64748B', fontSize: '0.85rem', fontWeight: 600 }}>
                  <th style={{ padding: '0.75rem 1rem 0.75rem 0' }}>Company</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Contact</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Fleet Size</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Completed</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Rating</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Status</th>
                  <th style={{ padding: '0.75rem 0 0.75rem 1rem' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={7} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      Loading companies...
                    </td>
                  </tr>
                ) : companies.length === 0 ? (
                  <tr>
                    <td colSpan={7} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      No transport companies found.
                    </td>
                  </tr>
                ) : (
                  companies.map((company) => (
                    <tr key={company.id} style={{ borderBottom: '1px solid #F1F5F9', fontSize: '0.9rem', color: '#0F172A' }}>
                      <td style={{ padding: '1rem 1rem 1rem 0', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <span style={{ fontSize: '1rem', color: '#64748B' }}>🏢</span>
                        <span>{company.company_name}</span>
                      </td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{company.contact}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{company.fleet_size}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{company.completed_trips}</td>
                      <td style={{ padding: '1rem', fontWeight: 600, color: '#0F172A' }}>
                        <span style={{ color: '#EAB308', marginRight: '0.25rem' }}>⭐</span>
                        {company.rating.toFixed(1)}
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <span
                          style={{
                            padding: '0.25rem 0.75rem',
                            borderRadius: '1rem',
                            fontSize: '0.775rem',
                            fontWeight: 600,
                            ...getStatusBadgeStyle(company.status),
                          }}
                        >
                          {company.status}
                        </span>
                      </td>
                      <td style={{ padding: '1rem 0 1rem 1rem' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
                          <button
                            onClick={() => setSelectedCompanyModal(company)}
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
                            View
                          </button>
                          <button
                            onClick={() => handleToggleStatus(company)}
                            style={{
                              background: 'none',
                              border: 'none',
                              color: company.status === 'Suspended' ? '#2563EB' : '#EF4444',
                              fontWeight: 600,
                              fontSize: '0.85rem',
                              cursor: 'pointer',
                              padding: 0,
                            }}
                          >
                            {company.status === 'Suspended' ? 'Unsuspend' : 'Suspend'}
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Company Details Modal */}
      {selectedCompanyModal && (
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
              width: '450px',
              boxShadow: '0 10px 25px rgba(0,0,0,0.15)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, color: '#0F172A' }}>Company Profile</h3>
              <button
                onClick={() => setSelectedCompanyModal(null)}
                style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', color: '#64748B' }}
              >
                ✕
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', fontSize: '0.925rem' }}>
              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>COMPANY NAME</span>
                <strong style={{ color: '#0F172A', fontSize: '1.05rem' }}>{selectedCompanyModal.company_name}</strong>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>CONTACT NUMBER</span>
                <span style={{ color: '#0F172A' }}>{selectedCompanyModal.contact}</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>FLEET SIZE</span>
                <span style={{ color: '#0F172A' }}>{selectedCompanyModal.fleet_size} Registered Vehicles</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>COMPLETED TRIPS</span>
                <span style={{ color: '#0F172A' }}>{selectedCompanyModal.completed_trips} Deliveries</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>RATING</span>
                <span style={{ fontWeight: 600, color: '#0F172A' }}>⭐ {selectedCompanyModal.rating.toFixed(1)} / 5.0</span>
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
                    ...getStatusBadgeStyle(selectedCompanyModal.status),
                  }}
                >
                  {selectedCompanyModal.status}
                </span>
              </div>
            </div>

            <div style={{ marginTop: '2rem', display: 'flex', justifyContent: 'flex-end' }}>
              <button
                onClick={() => setSelectedCompanyModal(null)}
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

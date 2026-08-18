import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface UserRecord {
  id: string;
  full_name: string;
  role: string;
  phone_number: string;
  status: 'Active' | 'Suspended' | 'Pending';
  created_at: string;
}

export default function AdminUsers() {
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUserModal, setSelectedUserModal] = useState<UserRecord | null>(null);

  const defaultUsers: UserRecord[] = [
    {
      id: 'USR-001',
      full_name: 'Sara Bekele',
      role: 'Shipper',
      phone_number: '+251 911 223 344',
      status: 'Active',
      created_at: 'Jan 2026',
    },
    {
      id: 'USR-002',
      full_name: 'Abebe Girma',
      role: 'Driver',
      phone_number: '+251 912 345 678',
      status: 'Active',
      created_at: 'Feb 2026',
    },
    {
      id: 'USR-003',
      full_name: 'Tesfaye Haile',
      role: 'Driver',
      phone_number: '+251 913 456 789',
      status: 'Suspended',
      created_at: 'Mar 2026',
    },
    {
      id: 'USR-004',
      full_name: 'Yohannes Alemu',
      role: 'Shipper',
      phone_number: '+251 922 112 233',
      status: 'Active',
      created_at: 'Apr 2026',
    },
    {
      id: 'USR-005',
      full_name: 'Tigist Worku',
      role: 'Fleet Owner',
      phone_number: '+251 933 445 566',
      status: 'Pending',
      created_at: 'Aug 2026',
    },
  ];

  const [users, setUsers] = useState<UserRecord[]>(defaultUsers);

  useEffect(() => {
    fetchUsers(searchTerm);
  }, [searchTerm]);

  const fetchUsers = async (searchQuery: string) => {
    try {
      setLoading(true);
      const queryParam = searchQuery ? `?search=${encodeURIComponent(searchQuery)}` : '';
      const res = await api.get<{
        success: boolean;
        data?: { users?: Record<string, unknown>[] };
      }>(`/admin/users${queryParam}`, true);

      if (res && res.success && res.data?.users && res.data.users.length > 0) {
        const fetchedUsers: UserRecord[] = res.data.users.map((u, index) => {
          const rawStatus = (u.status as string) || (u.is_verified ? 'ACTIVE' : 'PENDING');
          let formattedStatus: 'Active' | 'Suspended' | 'Pending' = 'Active';
          if (rawStatus.toUpperCase() === 'SUSPENDED') formattedStatus = 'Suspended';
          if (rawStatus.toUpperCase() === 'PENDING') formattedStatus = 'Pending';

          const joinedDate = u.created_at
            ? new Date(u.created_at as string).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
            : 'Jan 2026';

          return {
            id: (u.id as string) || `USR-00${index + 1}`,
            full_name: (u.full_name as string) || (u.name as string) || 'User Name',
            role: (u.role as string) ? (u.role as string).replace('_', ' ').toLowerCase().replace(/\b\w/g, l => l.toUpperCase()) : 'Shipper',
            phone_number: (u.phone_number as string) || (u.phone as string) || '+251 900 000 000',
            status: formattedStatus,
            created_at: joinedDate,
          };
        });
        setUsers(fetchedUsers);
      } else {
        // Local filtering on mock data if backend has no results
        if (searchQuery) {
          const lower = searchQuery.toLowerCase();
          setUsers(
            defaultUsers.filter(
              (u) =>
                u.full_name.toLowerCase().includes(lower) ||
                u.phone_number.includes(lower) ||
                u.role.toLowerCase().includes(lower)
            )
          );
        } else {
          setUsers(defaultUsers);
        }
      }
    } catch {
      // Fallback filter
      if (searchQuery) {
        const lower = searchQuery.toLowerCase();
        setUsers(
          defaultUsers.filter(
            (u) =>
              u.full_name.toLowerCase().includes(lower) ||
              u.phone_number.includes(lower) ||
              u.role.toLowerCase().includes(lower)
          )
        );
      } else {
        setUsers(defaultUsers);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleToggleStatus = async (user: UserRecord) => {
    const isCurrentlySuspended = user.status === 'Suspended';
    const actionEndpoint = isCurrentlySuspended ? `/admin/users/${user.id}/activate` : `/admin/users/${user.id}/suspend`;

    // Optimistic UI update
    setUsers((prev) =>
      prev.map((u) => {
        if (u.id === user.id) {
          return {
            ...u,
            status: isCurrentlySuspended ? 'Active' : 'Suspended',
          };
        }
        return u;
      })
    );

    try {
      await api.post(actionEndpoint, {}, true);
    } catch (err) {
      console.warn(`Status toggle performed in UI state for user ${user.id}`, err);
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
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Users</h1>
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

        {/* Main Users Table Card */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            borderRadius: '0.85rem',
            padding: '1.75rem 2rem',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            border: '1px solid #E2E8F0',
          }}
        >
          {/* Card Header & Search Box */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.75rem' }}>
            <h2 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>All Users</h2>

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
                  <th style={{ padding: '0.75rem 1rem 0.75rem 0' }}>Name</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Role</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Phone</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Status</th>
                  <th style={{ padding: '0.75rem 1rem' }}>Joined</th>
                  <th style={{ padding: '0.75rem 0 0.75rem 1rem' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={6} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      Loading users...
                    </td>
                  </tr>
                ) : users.length === 0 ? (
                  <tr>
                    <td colSpan={6} style={{ padding: '2rem', textAlign: 'center', color: '#64748B' }}>
                      No users found.
                    </td>
                  </tr>
                ) : (
                  users.map((user) => (
                    <tr key={user.id} style={{ borderBottom: '1px solid #F1F5F9', fontSize: '0.9rem', color: '#0F172A' }}>
                      <td style={{ padding: '1rem 1rem 1rem 0', fontWeight: 700 }}>{user.full_name}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{user.role}</td>
                      <td style={{ padding: '1rem', color: '#475569' }}>{user.phone_number}</td>
                      <td style={{ padding: '1rem' }}>
                        <span
                          style={{
                            padding: '0.25rem 0.75rem',
                            borderRadius: '1rem',
                            fontSize: '0.775rem',
                            fontWeight: 600,
                            ...getStatusBadgeStyle(user.status),
                          }}
                        >
                          {user.status}
                        </span>
                      </td>
                      <td style={{ padding: '1rem', color: '#64748B' }}>{user.created_at}</td>
                      <td style={{ padding: '1rem 0 1rem 1rem' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.85rem' }}>
                          <button
                            onClick={() => setSelectedUserModal(user)}
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
                            onClick={() => handleToggleStatus(user)}
                            style={{
                              background: 'none',
                              border: 'none',
                              color: user.status === 'Suspended' ? '#2563EB' : '#EF4444',
                              fontWeight: 600,
                              fontSize: '0.85rem',
                              cursor: 'pointer',
                              padding: 0,
                            }}
                          >
                            {user.status === 'Suspended' ? 'Unsuspend' : 'Suspend'}
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

      {/* User Details Modal */}
      {selectedUserModal && (
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
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, color: '#0F172A' }}>User Profile</h3>
              <button
                onClick={() => setSelectedUserModal(null)}
                style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', color: '#64748B' }}
              >
                ✕
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', fontSize: '0.925rem' }}>
              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>FULL NAME</span>
                <strong style={{ color: '#0F172A' }}>{selectedUserModal.full_name}</strong>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>ROLE</span>
                <span style={{ color: '#0F172A' }}>{selectedUserModal.role}</span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>PHONE NUMBER</span>
                <span style={{ color: '#0F172A' }}>{selectedUserModal.phone_number}</span>
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
                    ...getStatusBadgeStyle(selectedUserModal.status),
                  }}
                >
                  {selectedUserModal.status}
                </span>
              </div>

              <div>
                <span style={{ color: '#64748B', display: 'block', fontSize: '0.8rem' }}>JOINED</span>
                <span style={{ color: '#0F172A' }}>{selectedUserModal.created_at}</span>
              </div>
            </div>

            <div style={{ marginTop: '2rem', display: 'flex', justifyContent: 'flex-end' }}>
              <button
                onClick={() => setSelectedUserModal(null)}
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

import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import DataTable, { Column } from '../../../components/DataTable';
import EmptyState from '../../../components/EmptyState';
import PageHeader from '../../../components/PageHeader';
import SearchBar from '../../../components/SearchBar';
import StatusBadge from '../../../components/StatusBadge';
import type { DriverRequest } from '../../../types/person2';

export default function IncomingRequests() {
  const [search, setSearch] = useState('');

  // TODO: Replace mock data with API response from GET /api/driver/requests/incoming
  const requests: DriverRequest[] = [];

  const filtered = useMemo(() => {
    if (!search) return requests;
    const q = search.toLowerCase();
    return requests.filter(
      (r) =>
        r.origin.toLowerCase().includes(q) ||
        r.destination.toLowerCase().includes(q) ||
        r.cargoType.toLowerCase().includes(q)
    );
  }, [requests, search]);

  const columns: Column<DriverRequest>[] = [
    { key: 'route', header: 'Route', render: (r) => `${r.origin} → ${r.destination}` },
    { key: 'cargo', header: 'Cargo', render: (r) => r.cargoType },
    { key: 'weight', header: 'Weight (t)', render: (r) => r.weight },
    { key: 'pickup', header: 'Pickup', render: (r) => r.pickupDate },
    { key: 'status', header: 'Status', render: (r) => <StatusBadge status={r.status} /> },
    {
      key: 'action',
      header: '',
      render: (r) => (
        <Link to={`/driver/requests/${r.id}`} className="btn-primary" style={{ padding: '0.4rem 1rem', fontSize: '0.85rem' }}>
          View
        </Link>
      ),
    },
  ];

  return (
    <div>
      <PageHeader title="Incoming Requests" subtitle="Shipment requests assigned to you" />
      <SearchBar value={search} onChange={setSearch} placeholder="Search requests..." />

      {filtered.length === 0 ? (
        <EmptyState
          title="No incoming requests"
          description="New shipment requests will appear here when shippers or fleet owners assign them to you."
        />
      ) : (
        <DataTable columns={columns} rows={filtered} rowKey={(r) => r.id} />
      )}
    </div>
  );
}

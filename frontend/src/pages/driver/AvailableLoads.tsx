import { useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import DataTable, { Column } from '../../components/DataTable';
import EmptyState from '../../components/EmptyState';
import PageHeader from '../../components/PageHeader';
import SearchBar from '../../components/SearchBar';
import StatusBadge from '../../components/StatusBadge';
import type { DriverRequest } from '../../types/person2';

export default function AvailableLoads() {
  const [search, setSearch] = useState('');

  // TODO: Replace mock data with API response from GET /api/driver/loads/available
  const loads: DriverRequest[] = [];

  const filtered = useMemo(() => {
    if (!search) return loads;
    const q = search.toLowerCase();
    return loads.filter(
      (l) =>
        l.origin.toLowerCase().includes(q) ||
        l.destination.toLowerCase().includes(q)
    );
  }, [loads, search]);

  const columns: Column<DriverRequest>[] = [
    { key: 'route', header: 'Route', render: (l) => `${l.origin} → ${l.destination}` },
    { key: 'cargo', header: 'Cargo', render: (l) => l.cargoType },
    { key: 'weight', header: 'Weight (t)', render: (l) => l.weight },
    { key: 'bids', header: 'Bids', render: (l) => l.bidCount ?? 0 },
    { key: 'status', header: 'Status', render: (l) => <StatusBadge status={l.status} /> },
    {
      key: 'action',
      header: '',
      render: (l) => (
        <Link to={`/driver/requests/${l.id}`} className="btn-primary" style={{ padding: '0.4rem 1rem', fontSize: '0.85rem' }}>
          View & Bid
        </Link>
      ),
    },
  ];

  return (
    <div>
      <PageHeader
        title="Available Shipments"
        subtitle="Browse open loads and submit your bid"
        actions={
          <Link to="/driver/bids/history" className="btn-outline">
            Bid History
          </Link>
        }
      />
      <SearchBar value={search} onChange={setSearch} placeholder="Search by route or cargo..." />

      {filtered.length === 0 ? (
        <EmptyState
          title="No available loads"
          description="Open shipment loads matching your routes will appear here."
        />
      ) : (
        <DataTable columns={columns} rows={filtered} rowKey={(l) => l.id} />
      )}
    </div>
  );
}

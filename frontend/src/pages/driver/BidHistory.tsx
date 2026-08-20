import DataTable, { Column } from '../../components/DataTable';
import EmptyState from '../../components/EmptyState';
import PageHeader from '../../components/PageHeader';
import StatusBadge from '../../components/StatusBadge';
import { useDriverBids, DriverBid } from '../../hooks/useDriverBids';

export default function BidHistory() {
  const { bids, loading, error } = useDriverBids();

  const columns: Column<DriverBid>[] = [
    {
      key: 'route',
      header: 'Route',
      render: (b) =>
        b.origin_city && b.destination_city
          ? `${b.origin_city} → ${b.destination_city}`
          : b.load_id,
    },
    { key: 'cargo', header: 'Cargo', render: (b) => b.cargo_description ?? '—' },
    { key: 'amount', header: 'Bid (ETB)', render: (b) => Number(b.bid_amount_etb).toLocaleString() },
    { key: 'status', header: 'Status', render: (b) => <StatusBadge status={b.status} /> },
    {
      key: 'date',
      header: 'Submitted',
      render: (b) =>
        b.created_at
          ? new Date(b.created_at).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
          : '—',
    },
  ];

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <PageHeader title="Bid History" subtitle="Track all bids you have submitted" />

      {loading ? (
        <div className="py-12 text-center">
          <div className="w-12 h-12 border-4 border-amber-500 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-slate-600 text-sm">Loading bids…</p>
        </div>
      ) : error ? (
        <div className="py-12 text-center text-red-500">{error}</div>
      ) : bids.length === 0 ? (
        <EmptyState
          title="No bids yet"
          description="Your submitted bids will appear here once you bid on available loads."
        />
      ) : (
        <DataTable columns={columns} rows={bids} rowKey={(b) => b.id} />
      )}
    </div>
  );
}

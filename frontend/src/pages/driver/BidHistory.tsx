import DataTable, { Column } from '../../components/DataTable';
import EmptyState from '../../components/EmptyState';
import PageHeader from '../../components/PageHeader';
import StatusBadge from '../../components/StatusBadge';
import type { DriverBid } from '../../types/person2';

export default function BidHistory() {
  // TODO: Replace mock data with API response from GET /api/driver/bids
  const bids: DriverBid[] = [];

  const columns: Column<DriverBid>[] = [
    { key: 'route', header: 'Route', render: (b) => b.route },
    { key: 'amount', header: 'Amount (ETB)', render: (b) => b.amount.toLocaleString() },
    { key: 'status', header: 'Status', render: (b) => <StatusBadge status={b.status} /> },
    { key: 'date', header: 'Submitted', render: (b) => b.submittedAt },
  ];

  return (
    <div>
      <PageHeader title="Bid History" subtitle="Track all bids you have submitted" />

      {bids.length === 0 ? (
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

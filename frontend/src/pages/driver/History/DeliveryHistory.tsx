import DataTable, { Column } from '../../../components/DataTable';
import EmptyState from '../../../components/EmptyState';
import PageHeader from '../../../components/PageHeader';
import StatusBadge from '../../../components/StatusBadge';
import type { DeliveryRecord } from '../../../types/person2';

export default function DeliveryHistory() {
  // TODO: Replace with API response from GET /api/driver/deliveries/history
  const history: DeliveryRecord[] = [];

  const columns: Column<DeliveryRecord>[] = [
    { key: 'route', header: 'Route', render: (d) => `${d.origin} → ${d.destination}` },
    { key: 'status', header: 'Status', render: (d) => <StatusBadge status={d.status} /> },
    { key: 'updated', header: 'Completed', render: (d) => d.updatedAt },
  ];

  return (
    <div>
      <PageHeader title="Delivery History" subtitle="Past completed and cancelled deliveries" />

      {history.length === 0 ? (
        <EmptyState title="No delivery history" description="Completed deliveries will appear here." />
      ) : (
        <DataTable columns={columns} rows={history} rowKey={(d) => d.id} />
      )}
    </div>
  );
}

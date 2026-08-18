import EmptyState from '../../../components/EmptyState';
import PageHeader from '../../../components/PageHeader';

export default function DriverMessages() {
  // TODO: Replace with API response from GET /api/driver/messages

  return (
    <div>
      <PageHeader title="Messages" subtitle="Communicate with shippers and fleet owners" />
      <EmptyState
        title="No messages"
        description="Conversations about your shipments and deliveries will appear here."
      />
    </div>
  );
}

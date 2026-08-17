interface StatusBadgeProps {
  status: string;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info';
}

const variantMap: Record<string, StatusBadgeProps['variant']> = {
  active: 'success',
  verified: 'success',
  approved: 'success',
  delivered: 'success',
  completed: 'success',
  accepted: 'success',
  pending: 'warning',
  in_transit: 'info',
  assigned: 'info',
  rejected: 'danger',
  suspended: 'danger',
  cancelled: 'danger',
  inactive: 'danger',
};

export default function StatusBadge({ status, variant }: StatusBadgeProps) {
  const resolved = variant ?? variantMap[status.toLowerCase()] ?? 'default';
  const label = status.replace(/_/g, ' ');

  return <span className={`p2-badge p2-badge--${resolved}`}>{label}</span>;
}

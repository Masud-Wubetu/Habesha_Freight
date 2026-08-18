import { ReactNode } from 'react';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  actions?: ReactNode;
}

export default function PageHeader({ title, subtitle, actions }: PageHeaderProps) {
  return (
    <div className="p2-page-header">
      <div>
        <h1 className="p2-page-title">{title}</h1>
        {subtitle && <p className="p2-page-subtitle">{subtitle}</p>}
      </div>
      {actions && <div className="p2-page-actions">{actions}</div>}
    </div>
  );
}

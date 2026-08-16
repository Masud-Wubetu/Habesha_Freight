interface RouteCardProps {
  from: string;
  to: string;
}

export default function RouteCard({ from, to }: RouteCardProps) {
  return (
    <div style={{
      backgroundColor: 'rgba(255,255,255,0.05)',
      padding: '1.5rem',
      borderRadius: '0.75rem',
      border: '1px solid rgba(255,255,255,0.08)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }}>
      <div>
        <div style={{ color: '#FFFFFF', fontWeight: '500', fontSize: '1.125rem' }}>
          {from}
        </div>
      </div>
      <div style={{ 
        display: 'flex', 
        flexDirection: 'column', 
        alignItems: 'center',
        color: '#C8933A',
        fontWeight: '300',
        fontSize: '0.875rem'
      }}>
        <span style={{ fontSize: '1.5rem' }}>→</span>
      </div>
      <div>
        <div style={{ color: '#FFFFFF', fontWeight: '500', fontSize: '1.125rem' }}>
          {to}
        </div>
      </div>
    </div>
  );
}
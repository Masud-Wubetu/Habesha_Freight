interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
}

export default function FeatureCard({ icon, title, description }: FeatureCardProps) {
  return (
    <div style={{
      backgroundColor: '#FFFFFF',
      padding: '1.5rem',
      borderRadius: '0.75rem',
      border: '1px solid #e8eaed',
      textAlign: 'center',
      transition: 'all 0.2s'
    }}
    onMouseEnter={(e) => {
      e.currentTarget.style.boxShadow = '0 4px 20px rgba(0,0,0,0.06)';
      e.currentTarget.style.transform = 'translateY(-2px)';
    }}
    onMouseLeave={(e) => {
      e.currentTarget.style.boxShadow = 'none';
      e.currentTarget.style.transform = 'translateY(0)';
    }}
    >
      <div style={{
        fontSize: '2.5rem',
        marginBottom: '1rem'
      }}>
        {icon}
      </div>
      <h3 style={{
        fontFamily: 'DM Sans, sans-serif',
        fontSize: '1.125rem',
        fontWeight: '500',
        color: '#0B1F33',
        marginBottom: '0.5rem'
      }}>
        {title}
      </h3>
      <p style={{ color: '#6b7280', fontSize: '0.95rem', lineHeight: '1.5' }}>
        {description}
      </p>
    </div>
  );
}
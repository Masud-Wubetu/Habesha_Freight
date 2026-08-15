interface StepCardProps {
  number: string;
  title: string;
}

export default function StepCard({ number, title }: StepCardProps) {
  return (
    <div style={{
      backgroundColor: '#FFFFFF',
      padding: '2rem 1.5rem',
      borderRadius: '0.75rem',
      border: '1px solid #e8eaed',
      textAlign: 'center'
    }}>
      <div style={{
        fontFamily: 'Instrument Serif, serif',
        fontSize: '4rem',
        color: 'rgba(200, 147, 58, 0.2)',
        marginBottom: '0.5rem'
      }}>
        {number}
      </div>
      <h3 style={{
        fontFamily: 'DM Sans, sans-serif',
        fontSize: '1.25rem',
        fontWeight: '500',
        color: '#0B1F33',
        marginBottom: '0.5rem'
      }}>
        {title}
      </h3>
      <p style={{ color: '#6b7280', fontSize: '0.95rem' }}>
        {number === '01' && 'Post your shipment details and requirements'}
        {number === '02' && 'Get competitive bids from trusted carriers'}
        {number === '03' && 'Choose a carrier and track in real-time'}
        {number === '04' && 'Receive confirmation and release payment'}
      </p>
    </div>
  );
}
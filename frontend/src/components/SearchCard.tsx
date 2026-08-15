export default function SearchCard() {
  return (
    <div className="search-grid" style={{
      backgroundColor: '#FFFFFF',
      borderRadius: '1rem',
      padding: '2rem',
      boxShadow: '0 8px 30px rgba(0,0,0,0.12)',
      display: 'grid',
      gridTemplateColumns: '1fr 1fr auto',
      gap: '1.5rem',
      alignItems: 'end'
    }}>
      <div>
        <label style={{ 
          display: 'block', 
          fontSize: '0.875rem', 
          fontWeight: '500', 
          color: '#4a4a4a',
          marginBottom: '0.5rem'
        }}>
          FROM
        </label>
        <select style={{
          width: '100%',
          padding: '0.75rem',
          border: '1px solid #e0e0e0',
          borderRadius: '0.5rem',
          fontSize: '1rem',
          backgroundColor: '#FFFFFF',
          color: '#1a1a1a',
          fontFamily: 'DM Sans, sans-serif'
        }}>
          <option>Select city</option>
          <option>Addis Ababa</option>
          <option>Adama</option>
          <option>Hawassa</option>
          <option>Dire Dawa</option>
          <option>Bahir Dar</option>
          <option>Mekelle</option>
          <option>Jimma</option>
        </select>
      </div>
      
      <div>
        <label style={{ 
          display: 'block', 
          fontSize: '0.875rem', 
          fontWeight: '500', 
          color: '#4a4a4a',
          marginBottom: '0.5rem'
        }}>
          TO
        </label>
        <select style={{
          width: '100%',
          padding: '0.75rem',
          border: '1px solid #e0e0e0',
          borderRadius: '0.5rem',
          fontSize: '1rem',
          backgroundColor: '#FFFFFF',
          color: '#1a1a1a',
          fontFamily: 'DM Sans, sans-serif'
        }}>
          <option>Select city</option>
          <option>Addis Ababa</option>
          <option>Adama</option>
          <option>Hawassa</option>
          <option>Dire Dawa</option>
          <option>Bahir Dar</option>
          <option>Mekelle</option>
          <option>Jimma</option>
        </select>
      </div>
      
      <button className="search-btn" style={{
        backgroundColor: '#C8933A',
        color: '#FFFFFF',
        padding: '0.75rem 2rem',
        border: 'none',
        borderRadius: '0.5rem',
        fontSize: '1rem',
        fontWeight: '500',
        fontFamily: 'DM Sans, sans-serif',
        cursor: 'pointer',
        transition: 'background-color 0.2s',
        whiteSpace: 'nowrap'
      }}
      onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#F0B84A'}
      onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#C8933A'}
      >
        Find a Truck
      </button>
    </div>
  );
}
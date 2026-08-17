import React, { useState } from 'react';

interface DeliveryHistoryItem {
  id: string;
  origin: string;
  destination: string;
  cargoType: string;
  date: string;
  price: string;
  status: 'Rated' | 'Rate now' | 'In Transit' | 'Delivered';
  rated?: boolean;
}

const DeliveryHistory: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');

  // Mock data - replace with API data later
  const deliveries: DeliveryHistoryItem[] = [
    {
      id: 'SHP-003',
      origin: 'Addis Ababa',
      destination: 'Bahir Dar',
      cargoType: 'Construction Materials',
      date: 'Aug 5, 2026',
      price: 'ETB 11,000',
      status: 'Rated',
      rated: true,
    },
    {
      id: 'FR-001',
      origin: 'Adama',
      destination: 'Dire Dawa',
      cargoType: 'General Goods',
      date: 'Jul 28, 2026',
      price: 'ETB 28,500',
      status: 'Rate now',
      rated: false,
    },
  ];

  const filteredDeliveries = deliveries.filter((delivery) =>
    searchTerm === '' ||
    delivery.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
    delivery.origin.toLowerCase().includes(searchTerm.toLowerCase()) ||
    delivery.destination.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div style={{ padding: '24px', maxWidth: '900px' }}>
      {/* Page Header */}
      <div style={{ marginBottom: '24px' }}>
        
        <p style={{ fontSize: '14px', color: '#8b8b9f', margin: '4px 0 0 0' }}>
          Wednesday, Aug 13, 2026
        </p>
      </div>

      {/* Delivery History Section */}
      <div>
      
        
        
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {filteredDeliveries.length === 0 ? (
            <div style={{ 
              textAlign: 'center', 
              padding: '40px', 
              color: '#8b8b9f',
              backgroundColor: '#f8f8fa',
              borderRadius: '12px',
            }}>
              No deliveries found
            </div>
          ) : (
            filteredDeliveries.map((delivery) => (
              <div 
                key={delivery.id}
                style={{
                  backgroundColor: '#ffffff',
                  borderRadius: '12px',
                  border: '1px solid #e8e8f0',
                  padding: '16px 20px',
                  display: 'flex',
                  flexWrap: 'wrap',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  transition: 'box-shadow 0.2s ease',
                }}
              >
                {/* Left Section: ID, Route, and Cargo */}
                <div style={{ flex: '1 1 60%' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px', flexWrap: 'wrap' }}>
                    <span style={{ 
                      fontSize: '15px', 
                      fontWeight: 600, 
                      color: '#1a1a2e' 
                    }}>
                      {delivery.id}
                    </span>
                    <span style={{ color: '#c8c8d8' }}>·</span>
                    <span style={{ 
                      fontSize: '15px', 
                      color: '#4a4a62',
                    }}>
                      {delivery.origin} → {delivery.destination}
                    </span>
                  </div>
                  
                  <div style={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    gap: '12px', 
                    fontSize: '13px', 
                    color: '#7a7a92',
                    flexWrap: 'wrap'
                  }}>
                    <span>{delivery.cargoType}</span>
                    <span style={{ color: '#d1d5db' }}>·</span>
                    <span>{delivery.date}</span>
                  </div>
                </div>

                {/* Right Section: Price and Status */}
                <div style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  gap: '16px',
                  flex: '1 1 auto',
                  justifyContent: 'flex-end',
                  marginTop: '8px',
                }}>
                  <span style={{ 
                    fontSize: '15px', 
                    fontWeight: 600, 
                    color: '#1a1a2e',
                    whiteSpace: 'nowrap'
                  }}>
                    {delivery.price}
                  </span>
                  
                  {/* Status Button */}
                  {delivery.rated ? (
                    <span style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '6px',
                      padding: '4px 16px',
                      borderRadius: '20px',
                      backgroundColor: '#f0fdf4',
                      color: '#16a34a',
                      fontSize: '13px',
                      fontWeight: 500,
                      border: '1px solid #bbf7d0',
                      whiteSpace: 'nowrap',
                    }}>
                      <span>✓</span>
                      Rated
                    </span>
                  ) : (
                    <button
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '6px',
                        padding: '4px 16px',
                        borderRadius: '20px',
                        backgroundColor: '#eff6ff',
                        color: '#2563eb',
                        fontSize: '13px',
                        fontWeight: 500,
                        border: '1px solid #bfdbfe',
                        whiteSpace: 'nowrap',
                        cursor: 'pointer',
                        transition: 'all 0.2s ease',
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = '#dbeafe';
                        e.currentTarget.style.borderColor = '#93c5fd';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = '#eff6ff';
                        e.currentTarget.style.borderColor = '#bfdbfe';
                      }}
                      onClick={() => alert(`Rate delivery ${delivery.id}`)}
                    >
                      Rate now
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default DeliveryHistory;
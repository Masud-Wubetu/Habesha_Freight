import React, { useState } from 'react';

interface RatingSummary {
  average: number;
  totalTrips: number;
  breakdown: {
    5: number;
    4: number;
    3: number;
    2: number;
    1: number;
  };
}

interface Review {
  id: string;
  customerName: string;
  rating: number;
  comment: string;
}

// Local PageHeader component
const PageHeader: React.FC<{ title: string; subtitle: string }> = ({ title, subtitle }) => {
  return (
    <div style={{ marginBottom: '24px', paddingBottom: '16px', borderBottom: '1px solid #e8e8f0' }}>
      <h1 style={{ fontSize: '24px', fontWeight: 700, color: '#1a1a2e', margin: 0 }}>
        {title}
      </h1>
      <p style={{ fontSize: '14px', color: '#7a7a92', margin: '4px 0 0 0' }}>
        {subtitle}
      </p>
    </div>
  );
};

// Local DashboardCard component
const DashboardCard: React.FC<{ 
  title: string; 
  value: string; 
  icon: string;
  iconBg: string;
}> = ({ title, value, icon, iconBg }) => {
  return (
    <div style={{
      backgroundColor: '#ffffff',
      borderRadius: '12px',
      border: '1px solid #e8e8f0',
      padding: '16px 20px',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
    }}>
      <div>
        <div style={{ fontSize: '12px', color: '#8b8b9f' }}>{title}</div>
        <div style={{ fontSize: '24px', fontWeight: 700, color: '#1a1a2e' }}>{value}</div>
      </div>
      <div style={{
        width: '40px',
        height: '40px',
        borderRadius: '10px',
        backgroundColor: iconBg,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: '20px',
      }}>
        {icon}
      </div>
    </div>
  );
};

const DriverRatings: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'breakdown' | 'reviews'>('breakdown');

  const summary: RatingSummary = {
    average: 4.8,
    totalTrips: 142,
    breakdown: {
      5: 120,
      4: 15,
      3: 5,
      2: 1,
      1: 1,
    },
  };

  const reviews: Review[] = [
    {
      id: '1',
      customerName: 'Sara Bekele',
      rating: 5,
      comment: 'Arrived on time, cargo perfectly secured.',
    },
    {
      id: '2',
      customerName: 'Yohannes Alemu',
      rating: 5,
      comment: 'Great service, very professional driver.',
    },
  ];

  const renderStars = (rating: number) => {
    return (
      <div style={{ display: 'flex', gap: '2px', fontSize: '16px' }}>
        {[1, 2, 3, 4, 5].map((star) => (
          <span key={star} style={{ color: star <= rating ? '#fbbf24' : '#d1d5db' }}>
            {star <= rating ? '⭐' : '☆'}
          </span>
        ))}
      </div>
    );
  };

  const renderRatingBar = (stars: number, count: number, total: number) => {
    const percentage = total > 0 ? (count / total) * 100 : 0;
    const labels: Record<number, string> = {
      5: '5 stars',
      4: '4 stars',
      3: '3 stars',
      2: '2 stars',
      1: '1 star',
    };

    return (
      <div key={stars} style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '6px' }}>
        <span style={{ fontSize: '13px', color: '#6b6b80', width: '60px' }}>{labels[stars]}</span>
        <div style={{ flex: 1, height: '6px', backgroundColor: '#f0f0f5', borderRadius: '4px', overflow: 'hidden' }}>
          <div style={{ height: '100%', backgroundColor: '#fbbf24', borderRadius: '4px', width: `${percentage}%` }} />
        </div>
        <span style={{ fontSize: '13px', color: '#8b8b9f', width: '30px', textAlign: 'right' }}>{count}</span>
      </div>
    );
  };

  const totalReviews = Object.values(summary.breakdown).reduce((a, b) => a + b, 0);

  return (
    <div style={{ padding: '24px', maxWidth: '1200px' }}>
      <PageHeader title="Ratings" subtitle="Wednesday, Aug 9, 2026" />

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', 
        gap: '16px',
        marginBottom: '24px'
      }}>
        <DashboardCard 
          title="Average Rating"
          value={summary.average.toString()}
          icon="⭐"
          iconBg="#fef3c7"
        />
        <DashboardCard 
          title="Total Trips"
          value={summary.totalTrips.toString()}
          icon="📈"
          iconBg="#dbeafe"
        />
        <DashboardCard 
          title="5-Star Ratings"
          value={summary.breakdown[5].toString()}
          icon="🏆"
          iconBg="#dcfce7"
        />
        <DashboardCard 
          title="On Time"
          value="98%"
          icon="✅"
          iconBg="#ede9fe"
        />
      </div>

      <div style={{ display: 'flex', gap: '4px', borderBottom: '1px solid #e8e8f0', marginBottom: '24px' }}>
        <button
          onClick={() => setActiveTab('breakdown')}
          style={{
            padding: '8px 20px',
            fontSize: '14px',
            fontWeight: 500,
            border: 'none',
            background: 'none',
            cursor: 'pointer',
            color: activeTab === 'breakdown' ? '#3b82f6' : '#6b6b80',
            borderBottom: activeTab === 'breakdown' ? '2px solid #3b82f6' : '2px solid transparent',
            marginBottom: '-1px',
          }}
        >
          Rating Breakdown
        </button>
        <button
          onClick={() => setActiveTab('reviews')}
          style={{
            padding: '8px 20px',
            fontSize: '14px',
            fontWeight: 500,
            border: 'none',
            background: 'none',
            cursor: 'pointer',
            color: activeTab === 'reviews' ? '#3b82f6' : '#6b6b80',
            borderBottom: activeTab === 'reviews' ? '2px solid #3b82f6' : '2px solid transparent',
            marginBottom: '-1px',
          }}
        >
          Reviews
        </button>
      </div>

      {activeTab === 'breakdown' && (
        <div style={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e8e8f0', padding: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
            <div style={{
              width: '48px',
              height: '48px',
              borderRadius: '50%',
              backgroundColor: '#fef3c7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '24px',
            }}>
              ⭐
            </div>
            <div>
              <div style={{ fontSize: '24px', fontWeight: 700, color: '#1a1a2e' }}>
                {summary.average} / 5.0
              </div>
              <div style={{ fontSize: '13px', color: '#6b6b80' }}>
                {totalReviews} total reviews
              </div>
            </div>
          </div>

          <h3 style={{ fontSize: '14px', fontWeight: 500, color: '#3a3a52', marginBottom: '16px' }}>
            Rating Distribution
          </h3>
          <div>
            {[5, 4, 3, 2, 1].map((stars) => {
              const count = summary.breakdown[stars as keyof typeof summary.breakdown];
              return renderRatingBar(stars, count, totalReviews);
            })}
          </div>
          <div style={{ marginTop: '16px', paddingTop: '16px', borderTop: '1px solid #f0f0f5', display: 'flex', justifyContent: 'space-between', fontSize: '14px', color: '#6b6b80' }}>
            <span>Total Reviews</span>
            <span style={{ fontWeight: 600, color: '#1a1a2e' }}>{totalReviews}</span>
          </div>
        </div>
      )}

      {activeTab === 'reviews' && (
        <div style={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e8e8f0', overflow: 'hidden' }}>
          {reviews.map((review, index) => (
            <div key={review.id} style={{ padding: '20px 24px', borderBottom: index < reviews.length - 1 ? '1px solid #f0f0f5' : 'none' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '4px' }}>
                <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#f0f0f5', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '14px', fontWeight: 600, color: '#4a4a62' }}>
                  {review.customerName.charAt(0)}
                </div>
                <span style={{ fontWeight: 500, color: '#1a1a2e' }}>{review.customerName}</span>
              </div>
              <div style={{ marginLeft: '44px' }}>
                {renderStars(review.rating)}
                <p style={{ marginTop: '8px', fontSize: '14px', color: '#5a5a72' }}>"{review.comment}"</p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default DriverRatings;
import React, { useState } from 'react';
import './BidHistory.css';

interface Bid {
  id: string;
  shipment: string;
  customer: string;
  pickup: string;
  destination: string;
  truckType: string;
  amount: string;
  date: string;
  status: 'Pending' | 'Accepted' | 'Rejected' | 'Completed';
}

const BidHistory: React.FC = () => {
  const [activeFilter, setActiveFilter] = useState('All');

  const bids: Bid[] = [
    {
      id: 'BID-1024',
      shipment: 'SHP-2048',
      customer: 'Abebe Transport',
      pickup: 'Addis Ababa',
      destination: 'Dire Dawa',
      truckType: 'Flatbed',
      amount: 'ETB 42,000',
      date: 'Aug 18, 2026',
      status: 'Pending',
    },
    {
      id: 'BID-1023',
      shipment: 'SHP-2042',
      customer: 'Ethiopian Trading',
      pickup: 'Adama',
      destination: 'Hawassa',
      truckType: 'Isuzu FSR',
      amount: 'ETB 28,500',
      date: 'Aug 17, 2026',
      status: 'Accepted',
    },
    {
      id: 'BID-1022',
      shipment: 'SHP-2037',
      customer: 'Habesha Foods',
      pickup: 'Addis Ababa',
      destination: 'Bahir Dar',
      truckType: 'Curtain Side',
      amount: 'ETB 36,000',
      date: 'Aug 15, 2026',
      status: 'Completed',
    },
    {
      id: 'BID-1021',
      shipment: 'SHP-2029',
      customer: 'Blue Nile Trading',
      pickup: 'Jimma',
      destination: 'Addis Ababa',
      truckType: 'Flatbed',
      amount: 'ETB 31,000',
      date: 'Aug 14, 2026',
      status: 'Rejected',
    },
  ];

  const filters = ['All', 'Pending', 'Accepted', 'Completed', 'Rejected'];

  const filteredBids =
    activeFilter === 'All'
      ? bids
      : bids.filter((bid) => bid.status === activeFilter);

  return (
    <div className="driver-bids-page">
      {/* Header */}
      <div className="driver-bids-header" style={{ justifyContent: 'flex-end' }}>

        <button className="submit-bid-btn">
          + Submit New Bid
        </button>
      </div>

      {/* Summary Cards */}
      <div className="bid-summary">
        <div className="bid-summary-card">
          <span>Total Bids</span>
          <strong>{bids.length}</strong>
        </div>

        <div className="bid-summary-card">
          <span>Pending</span>
          <strong>
            {bids.filter((bid) => bid.status === 'Pending').length}
          </strong>
        </div>

        <div className="bid-summary-card">
          <span>Accepted</span>
          <strong>
            {bids.filter((bid) => bid.status === 'Accepted').length}
          </strong>
        </div>

        <div className="bid-summary-card">
          <span>Completed</span>
          <strong>
            {bids.filter((bid) => bid.status === 'Completed').length}
          </strong>
        </div>
      </div>

      {/* Main Card */}
      <div className="bids-card">
        <div className="bids-card-header">
          <h2>Bid History</h2>

          <div className="bid-filters">
            {filters.map((filter) => (
              <button
                key={filter}
                className={activeFilter === filter ? 'active' : ''}
                onClick={() => setActiveFilter(filter)}
              >
                {filter}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <div className="bids-table-wrapper">
          <table className="bids-table">
            <thead>
              <tr>
                <th>Bid ID</th>
                <th>Shipment</th>
                <th>Customer</th>
                <th>Route</th>
                <th>Truck</th>
                <th>Amount</th>
                <th>Date</th>
                <th>Status</th>
              </tr>
            </thead>

            <tbody>
              {filteredBids.map((bid) => (
                <tr key={bid.id}>
                  <td className="bid-id">{bid.id}</td>

                  <td>{bid.shipment}</td>

                  <td>{bid.customer}</td>

                  <td>
                    <div className="bid-route">
                      <span>{bid.pickup}</span>
                      <span className="route-arrow">→</span>
                      <span>{bid.destination}</span>
                    </div>
                  </td>

                  <td>{bid.truckType}</td>

                  <td className="bid-amount">{bid.amount}</td>

                  <td>{bid.date}</td>

                  <td>
                    <span
                      className={`bid-status ${bid.status.toLowerCase()}`}
                    >
                      {bid.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {filteredBids.length === 0 && (
            <div className="no-bids">
              No bids found for this status.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default BidHistory;
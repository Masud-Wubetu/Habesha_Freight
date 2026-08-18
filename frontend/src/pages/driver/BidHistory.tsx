import React from 'react';
import './BidHistory.css';

export default function BidHistory() {
  return (
    <div className="bids-container">
      {/* Header */}
      <header className="bids-header">
        <div className="header-left">
          <h1 className="bids-page-title">My Bids</h1>
          <p className="header-date">Wednesday, Aug 9, 2026</p>
        </div>
        <div className="header-right">
          <div className="status-badge online">
            <span className="dot"></span> Online & Available
          </div>
          <button className="theme-toggle-btn">🌙</button>
          <div className="user-avatar-circle">AG</div>
        </div>
      </header>

      {/* Main Content */}
      <main className="bids-main">
        {/* Filter Bar */}
        <div className="filter-bar">
          <select className="filter-dropdown">
            <option>All Statuses</option>
            <option>Pending</option>
            <option>Accepted</option>
            <option>Rejected</option>
          </select>
          <select className="filter-dropdown">
            <option>All Routes</option>
          </select>
          <select className="filter-dropdown">
            <option>Recent First</option>
          </select>
        </div>

        {/* Bid Cards */}
        <div className="bid-cards-list">
          {/* Card 1 */}
          <div className="bid-card">
            <div className="bid-card-top">
              <div className="bid-details-left">
                <h2 className="bid-route">Addis Ababa → Hawassa</h2>
                <p className="bid-specs">Agricultural Produce · 12 tons · 275 km</p>
                <p className="bid-shipper">Shipper: Haile Trading</p>
              </div>
              <div className="bid-details-right">
                <h2 className="bid-price">ETB 9,200</h2>
                <p className="bid-price-label">Your Bid</p>
                <span className="bid-status-badge pending">Pending</span>
              </div>
            </div>
            <div className="bid-actions">
              <button className="view-details-btn">View Load Details</button>
              <button className="edit-bid-btn">Update Bid</button>
              <button className="chat-btn">💬</button>
            </div>
          </div>

          {/* Card 2 */}
          <div className="bid-card">
            <div className="bid-card-top">
              <div className="bid-details-left">
                <h2 className="bid-route">
                  Adama → Dire Dawa <span className="urgent-badge">Urgent</span>
                </h2>
                <p className="bid-specs">Electronics · 5 tons · 340 km</p>
                <p className="bid-shipper">Shipper: Tigist Imports</p>
              </div>
              <div className="bid-details-right">
                <h2 className="bid-price">ETB 6,800</h2>
                <p className="bid-price-label">Your Bid</p>
                <span className="bid-status-badge accepted">Accepted</span>
              </div>
            </div>
            <div className="bid-actions">
              <button className="primary-action-btn">Start Delivery</button>
              <button className="view-details-btn">View Waybill</button>
              <button className="chat-btn">💬</button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

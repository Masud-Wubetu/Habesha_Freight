import React from 'react';
import './CompanyProfile.css';

const CompanyProfile: React.FC = () => {
  return (
    <div className="company-profile-page">
      <div className="company-profile-card">

        {/* Company Header */}
        <div className="company-profile-header">

          <div className="company-logo">
            🏢
          </div>

          <div className="company-main-info">
            <div className="company-name-row">
              <h1>Ethio Transport Solutions</h1>
              <span className="verified-badge">
                ✓ Verified
              </span>
            </div>

            <p className="company-location">
              Established 2018 · Addis Ababa, Ethiopia
            </p>

            <div className="company-stats">
              <span>⭐ 4.8 (127 reviews)</span>
              <span>·</span>
              <span>🚚 5 trucks</span>
              <span>·</span>
              <span>115 deliveries</span>
            </div>
          </div>

          <div className="profile-actions">
            <button className="edit-profile-btn">
              Edit Profile
            </button>

            <button className="upload-logo-btn">
              Upload Logo
            </button>
          </div>

        </div>

        {/* Company Information */}
        <div className="company-info-grid">

          <div className="info-box">
            <span className="info-label">
              Contact Phone
            </span>
            <span className="info-value">
              +251 911 234 567
            </span>
          </div>

          <div className="info-box">
            <span className="info-label">
              Email
            </span>
            <span className="info-value">
              info@ethiotransport.et
            </span>
          </div>

          <div className="info-box">
            <span className="info-label">
              Service Area
            </span>
            <span className="info-value">
              All major Ethiopian cities
            </span>
          </div>

          <div className="info-box">
            <span className="info-label">
              Vehicle Types
            </span>
            <span className="info-value">
              Flatbed, Refrigerated, Tanker, Box
            </span>
          </div>

          <div className="info-box">
            <span className="info-label">
              Fleet Size
            </span>
            <span className="info-value">
              5 vehicles
            </span>
          </div>

          <div className="info-box">
            <span className="info-label">
              Years in Business
            </span>
            <span className="info-value">
              8 years
            </span>
          </div>

        </div>

      </div>
    </div>
  );
};

export default CompanyProfile;

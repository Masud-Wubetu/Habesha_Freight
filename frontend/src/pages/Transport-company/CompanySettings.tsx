import React, { useState } from 'react';
import './CompanySettings.css';

const CompanySettings: React.FC = () => {
  const [formData, setFormData] = useState({
    companyName: 'Ethio Transport Solutions',
    contactPhone: '+251 911 234 567',
    email: 'info@ethiotransport.et',
    serviceArea: 'All major Ethiopian cities',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Saved', formData);
  };

  return (
    <div className="company-settings-container">
      {/* Top Header matching the UI */}
      <header className="settings-header" style={{ justifyContent: 'flex-end', padding: '10px 0' }}>
        <div className="settings-header-right">
          <button className="pending-request-btn">
            <span className="icon">📄</span> 1 pending request
          </button>
          <button className="theme-toggle-btn">
            🌙
          </button>
          <div className="user-avatar-circle">
            ET
          </div>
        </div>
      </header>

      {/* Main Settings Card */}
      <div className="settings-content">
        <div className="settings-card">
          <h2 className="settings-card-title">Company Settings</h2>
          
          <form className="settings-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="companyName">Company Name</label>
              <input
                type="text"
                id="companyName"
                name="companyName"
                value={formData.companyName}
                onChange={handleChange}
              />
            </div>

            <div className="form-group">
              <label htmlFor="contactPhone">Contact Phone</label>
              <input
                type="text"
                id="contactPhone"
                name="contactPhone"
                value={formData.contactPhone}
                onChange={handleChange}
              />
            </div>

            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
              />
            </div>

            <div className="form-group">
              <label htmlFor="serviceArea">Service Area</label>
              <input
                type="text"
                id="serviceArea"
                name="serviceArea"
                value={formData.serviceArea}
                onChange={handleChange}
              />
            </div>

            <button type="submit" className="save-changes-btn">
              Save Changes
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default CompanySettings;

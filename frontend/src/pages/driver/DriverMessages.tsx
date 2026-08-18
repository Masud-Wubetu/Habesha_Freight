import React from 'react';
import './DriverMessages.css';

export default function DriverMessages() {
  return (
    <div className="driver-messages-container">
      {/* Top Header */}
      <header className="messages-top-header">
        <div className="header-left">
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

      {/* Main Content Split View */}
      <div className="messages-main">
        {/* Left Sidebar */}
        <aside className="messages-sidebar">
          <h2 className="sidebar-title">Messages</h2>
          
          <div className="conversation-list">
            {/* Active Conversation */}
            <div className="conversation-item active">
              <div className="convo-avatar sb-avatar">SB</div>
              <div className="convo-details">
                <div className="convo-header">
                  <span className="convo-name">Sara Bekele</span>
                  <span className="convo-time">5m ago</span>
                </div>
                <div className="convo-preview">
                  <span className="preview-text">Please be at Kaliti gate at 7 AM.</span>
                  <span className="unread-badge">1</span>
                </div>
              </div>
            </div>

            {/* Inactive Conversation */}
            <div className="conversation-item">
              <div className="convo-avatar hf-avatar">HF</div>
              <div className="convo-details">
                <div className="convo-header">
                  <span className="convo-name">HabeshaFreight</span>
                  <span className="convo-time">1d ago</span>
                </div>
                <div className="convo-preview">
                  <span className="preview-text">Your verification badge has been renew...</span>
                </div>
              </div>
            </div>
          </div>
        </aside>

        {/* Right Chat Area */}
        <section className="chat-area">
          {/* Chat Header */}
          <header className="chat-header">
            <div className="chat-header-avatar sb-avatar">SB</div>
            <div className="chat-header-info">
              <h3 className="chat-header-name">Sara Bekele</h3>
              <p className="chat-header-status">
                <span className="dot"></span> Online · SHP-001
              </p>
            </div>
          </header>

          {/* Chat Messages */}
          <div className="chat-messages">
            <div className="message-row received">
              <div className="message-bubble">
                Please be at Kaliti gate at 7 AM.
              </div>
            </div>

            <div className="message-row sent">
              <div className="message-bubble">
                Understood. Will I need to bring any documents?
              </div>
            </div>

            <div className="message-row received">
              <div className="message-bubble">
                Just your license and truck registration. We'll handle the rest.
              </div>
            </div>
          </div>
          
          {/* Input Area placeholder to match realism if needed, or leave empty if exactly matching image bounds */}
        </section>
      </div>
    </div>
  );
}

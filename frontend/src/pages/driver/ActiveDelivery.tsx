import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getStoredUser } from '../../services/authService';
import '../../styles/active-delivery.css';

/* ── Types ───────────────────────────────────────────────── */
interface Message {
  id: number;
  text: string;
  from: 'me' | 'them';
}

interface Conversation {
  id: string;
  name: string;
  initials: string;
  avatarGold?: boolean;
  preview: string;
  time: string;
  unread?: number;
  messages: Message[];
}

/* ── Mock data ───────────────────────────────────────────── */
const CONVERSATIONS: Conversation[] = [
  {
    id: 'sara',
    name: 'Sara Bekele',
    initials: 'SB',
    preview: 'Please be at Kaliti gate at 7 AM.',
    time: '5m ago',
    unread: 1,
    messages: [
      { id: 1, text: 'Please be at Kaliti gate at 7 AM.', from: 'them' },
      { id: 2, text: 'Understood. Will I need to bring any documents?', from: 'me' },
      { id: 3, text: 'Just your license and truck registration. We\'ll handle the rest.', from: 'them' },
    ],
  },
  {
    id: 'hf',
    name: 'HabeshaFreight',
    initials: 'HF',
    avatarGold: true,
    preview: 'Your verification badge has been renew…',
    time: '1d ago',
    messages: [
      { id: 1, text: 'Your verification badge has been renewed. You are now fully cleared for transit.', from: 'them' },
      { id: 2, text: 'Thank you! Appreciate the update.', from: 'me' },
    ],
  },
];

/* ── Helper: today's date string ─────────────────────────── */
function formatDate() {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long', month: 'short', day: 'numeric', year: 'numeric',
  });
}

/* ── Main component ──────────────────────────────────────── */
export default function ActiveDelivery() {

  const navigate = useNavigate();
  const storedUser = getStoredUser();

  const initials = (storedUser?.full_name ?? 'AG')
    .split(' ')
    .map((w: string) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  /* Delivery status state */
  type Step = 'pending' | 'loaded' | 'checkpoint' | 'delivered';
  const [step, setStep] = useState<Step>('pending');

  const stepDone = (s: Step) => {
    const order: Step[] = ['pending', 'loaded', 'checkpoint', 'delivered'];
    return order.indexOf(step) > order.indexOf(s);
  };
  const stepCurrent = (s: Step) => step === s;

  /* Chat state */
  const [chatOpen, setChatOpen]     = useState(false);
  const [activeConvId, setActiveConvId] = useState(CONVERSATIONS[0].id);
  const [drafts, setDrafts]         = useState<Record<string, string>>({});
  const [convList, setConvList]     = useState<Conversation[]>(CONVERSATIONS);
  const messagesEndRef               = useRef<HTMLDivElement>(null);

  const activeConv = convList.find((c) => c.id === activeConvId)!;
  const draft      = drafts[activeConvId] ?? '';

  const openChat = () => {
    // clear unread on open
    setConvList((prev) =>
      prev.map((c) => (c.id === activeConvId ? { ...c, unread: 0 } : c))
    );
    setChatOpen(true);
  };

  const selectConv = (id: string) => {
    setActiveConvId(id);
    setConvList((prev) =>
      prev.map((c) => (c.id === id ? { ...c, unread: 0 } : c))
    );
  };

  const sendMessage = () => {
    if (!draft.trim()) return;
    const newMsg: Message = { id: Date.now(), text: draft.trim(), from: 'me' };
    setConvList((prev) =>
      prev.map((c) =>
        c.id === activeConvId
          ? { ...c, messages: [...c.messages, newMsg], preview: draft.trim() }
          : c
      )
    );
    setDrafts((d) => ({ ...d, [activeConvId]: '' }));
    setTimeout(() => messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 50);
  };

  /* TODO: Replace mock delivery with API data */
  const delivery = {
    shipmentId: 'SHP-001',
    origin: 'Addis Ababa',
    destination: 'Dire Dawa',
    cargoType: 'Electronics',
    weightTons: 8,
    budgetETB: 8500,
    status: 'In Transit',
  };

  return (
    <>
      <div className="ad-page">

        {/* ── Page Header ──────────────────────────────────── */}
        <div className="ad-header">
          <div className="ad-header-left">
            <h1>Active Delivery</h1>
            <p className="ad-date">{formatDate()}</p>
          </div>
          <div className="ad-header-right">
            <div className="ad-status-badge">
              <span className="ad-status-dot" />
              Online &amp; Available
            </div>
            <button className="ad-theme-toggle" aria-label="Toggle dark mode">🌙</button>
            <div className="ad-avatar" title={storedUser?.full_name ?? 'Abebe Girma'}>
              {initials}
            </div>
          </div>
        </div>

        {/* ── Delivery Card ─────────────────────────────────── */}
        <div className="ad-card">

          {/* Top: shipment info + price */}
          <div className="ad-card-top">
            <div>
              <p className="ad-shipment-id">
                {delivery.shipmentId} · {delivery.origin} → {delivery.destination}
              </p>
              <p className="ad-shipment-meta">
                {delivery.cargoType} · {delivery.weightTons} tons
              </p>
            </div>
            <div className="ad-price-wrap">
              <p className="ad-price">ETB {delivery.budgetETB.toLocaleString()}</p>
              <span className={`ad-pill ${
                step === 'delivered' ? 'ad-pill--delivered' :
                step === 'loaded'    ? 'ad-pill--loaded' :
                'ad-pill--transit'
              }`}>
                {step === 'delivered' ? 'Delivered' :
                 step === 'loaded'    ? 'Loaded' :
                 'In Transit'}
              </span>
            </div>
          </div>

          {/* Status action rows */}
          <div className="ad-actions-list">

            {/* Mark as Loaded */}
            <div
              className={`ad-action-row ${stepDone('pending') ? 'ad-action-row--done' : ''}`}
              onClick={() => { if (stepCurrent('pending')) setStep('loaded'); }}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => e.key === 'Enter' && stepCurrent('pending') && setStep('loaded')}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">{stepDone('pending') ? '✅' : '📦'}</span>
                Mark as Loaded
              </span>
              <span className="ad-action-arrow">→</span>
            </div>

            {/* Arrived at Checkpoint */}
            <div
              className={`ad-action-row ${stepDone('loaded') ? 'ad-action-row--done' : ''}`}
              onClick={() => { if (stepCurrent('loaded')) setStep('checkpoint'); }}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => e.key === 'Enter' && stepCurrent('loaded') && setStep('checkpoint')}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">{stepDone('loaded') ? '✅' : '🚩'}</span>
                Arrived at Checkpoint
              </span>
              <span className="ad-action-arrow">→</span>
            </div>

            {/* Mark as Delivered */}
            <div
              className={`ad-action-row ${stepDone('checkpoint') ? 'ad-action-row--done' : ''}`}
              onClick={() => { if (stepCurrent('checkpoint')) setStep('delivered'); }}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => e.key === 'Enter' && stepCurrent('checkpoint') && setStep('delivered')}
            >
              <span className="ad-action-label">
                <span className="ad-action-icon">{stepDone('checkpoint') ? '✅' : '🏁'}</span>
                Mark as Delivered
              </span>
              <span className="ad-action-arrow">→</span>
            </div>
          </div>

          {/* Navigation + Chat buttons */}
          <div className="ad-bottom-actions">
            <button
              className="ad-bottom-btn"
              onClick={() => navigate('/driver/active-delivery/tracking')}
            >
              <span className="ad-btn-emoji">📍</span>
              Navigation
            </button>
            <button className="ad-bottom-btn" onClick={openChat}>
              <span className="ad-btn-emoji">💬</span>
              Chat
            </button>
          </div>
        </div>

      </div>

      {/* ── Chat Panel ───────────────────────────────────────── */}
      {chatOpen && (
        <div className="chat-overlay" onClick={() => setChatOpen(false)}>
          <div className="chat-panel" onClick={(e) => e.stopPropagation()}>

            {/* Conversation sidebar */}
            <div className="chat-sidebar">
              <div className="chat-sidebar-header">
                <p className="chat-sidebar-title">Messages</p>
              </div>
              <div className="chat-conv-list">
                {convList.map((conv) => (
                  <div
                    key={conv.id}
                    className={`chat-conv-item ${conv.id === activeConvId ? 'chat-conv-item--active' : ''}`}
                    onClick={() => selectConv(conv.id)}
                  >
                    <div className={`chat-conv-avatar ${conv.avatarGold ? 'chat-conv-avatar--gold' : ''}`}>
                      {conv.initials}
                    </div>
                    <div className="chat-conv-body">
                      <p className="chat-conv-name">{conv.name}</p>
                      <p className="chat-conv-preview">{conv.preview}</p>
                    </div>
                    <div>
                      <p className="chat-conv-time">{conv.time}</p>
                    </div>
                    {conv.unread ? (
                      <div className="chat-unread">{conv.unread}</div>
                    ) : null}
                  </div>
                ))}
              </div>
            </div>

            {/* Message area */}
            <div className="chat-main">
              <div className="chat-main-header">
                <p className="chat-main-title">{activeConv.name}</p>
                <button className="chat-close-btn" onClick={() => setChatOpen(false)}>✕</button>
              </div>

              <div className="chat-messages">
                {activeConv.messages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`chat-bubble ${msg.from === 'me' ? 'chat-bubble--out' : 'chat-bubble--in'}`}
                  >
                    {msg.text}
                  </div>
                ))}
                <div ref={messagesEndRef} />
              </div>

              <div className="chat-input-bar">
                <input
                  className="chat-input"
                  placeholder="Type a message..."
                  value={draft}
                  onChange={(e) => setDrafts((d) => ({ ...d, [activeConvId]: e.target.value }))}
                  onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
                />
                <button className="chat-send-btn" onClick={sendMessage}>Send</button>
              </div>
            </div>

          </div>
        </div>
      )}
    </>
  );
}

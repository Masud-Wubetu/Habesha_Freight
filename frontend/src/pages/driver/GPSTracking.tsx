import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import GoogleMapView from '../../components/GoogleMapView';
import { post } from '../../services/api';

export default function GPSTracking() {
  const navigate = useNavigate();

  const [isBroadcasting, setIsBroadcasting] = useState(true);
  const [currentLat, setCurrentLat] = useState(8.9806);
  const [currentLng, setCurrentLng] = useState(38.7578);
  const [speed, setSpeed] = useState(65);
  const [lastUpdate, setLastUpdate] = useState<string>('Just now');
  const [broadcastStatus, setBroadcastStatus] = useState<string>('Live GPS Broadcasting Active');

  // Ethiopian route preset coordinates
  const origin = { lat: 9.0300, lng: 38.7400, label: 'Addis Ababa' };
  const destination = { lat: 9.6000, lng: 41.8600, label: 'Dire Dawa' };

  // Simulated GPS Telemetry Broadcast interval
  useEffect(() => {
    if (!isBroadcasting) return;

    const interval = setInterval(async () => {
      // Simulate small latitude/longitude progression along the route
      const nextLat = currentLat + (Math.random() - 0.48) * 0.005;
      const nextLng = currentLng + 0.008;
      const nextSpeed = Math.floor(60 + Math.random() * 15);

      setCurrentLat(nextLat);
      setCurrentLng(nextLng);
      setSpeed(nextSpeed);
      setLastUpdate(new Date().toLocaleTimeString());

      try {
        await post('/tracking/location', {
          shipment_id: 'SHP-001',
          latitude: nextLat,
          longitude: nextLng,
          speed: nextSpeed,
        });
        setBroadcastStatus('Telemetry point broadcasted to server ✓');
      } catch (err) {
        // Silently capture broadcast error or mock status
        setBroadcastStatus('Telemetry updated locally');
      }
    }, 8000);

    return () => clearInterval(interval);
  }, [isBroadcasting, currentLat, currentLng]);

  return (
    <div className="p-6 max-w-6xl mx-auto font-sans text-slate-900 min-h-screen">
      {/* Back button */}
      <div className="flex justify-between items-center mb-6">
        <button
          className="flex items-center gap-2 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-sm font-semibold transition-colors"
          onClick={() => navigate('/driver/active-delivery')}
        >
          ← Back to Active Delivery
        </button>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setIsBroadcasting(!isBroadcasting)}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer ${
              isBroadcasting
                ? 'bg-emerald-600 hover:bg-emerald-700 text-white'
                : 'bg-amber-500 hover:bg-amber-600 text-slate-950'
            }`}
          >
            <span className={`w-2 h-2 rounded-full ${isBroadcasting ? 'bg-white animate-ping' : 'bg-slate-950'}`} />
            {isBroadcasting ? 'Broadcasting GPS Telemetry' : 'Resume Telemetry Broadcast'}
          </button>
        </div>
      </div>

      {/* Header */}
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xl font-black text-slate-900">SHP-001</span>
            <span className="px-2.5 py-0.5 rounded-full bg-blue-100 text-blue-800 text-xs font-bold">
              IN TRANSIT
            </span>
          </div>
          <p className="text-sm font-semibold text-slate-600">
            {origin.label} ➔ {destination.label} · Ethiopian Highway Route
          </p>
        </div>

        <div className="text-right">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Broadcast Status</p>
          <p className="text-xs font-bold text-emerald-600 mt-0.5">{broadcastStatus}</p>
        </div>
      </div>

      {/* Integrated Interactive Google Map */}
      <div className="mb-6">
        <GoogleMapView
          driverPos={{ lat: currentLat, lng: currentLng, label: 'Your Truck' }}
          originPos={origin}
          destinationPos={destination}
          speed={speed}
          height="420px"
        />
      </div>

      {/* Real-time Telemetry Dashboard Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center text-2xl font-black">
            🚀
          </div>
          <div>
            <p className="text-2xl font-bold text-slate-900">{speed} <span className="text-xs font-normal text-slate-400">km/h</span></p>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Current Speed</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-2xl font-black">
            📏
          </div>
          <div>
            <p className="text-2xl font-bold text-slate-900">340 <span className="text-xs font-normal text-slate-400">km</span></p>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Distance Remaining</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-2xl font-black">
            🕐
          </div>
          <div>
            <p className="text-2xl font-bold text-slate-900">4.5 <span className="text-xs font-normal text-slate-400">hrs</span></p>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Estimated Time (ETA)</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center text-2xl font-black">
            📡
          </div>
          <div>
            <p className="text-sm font-bold text-slate-900 truncate">{lastUpdate}</p>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Last Telemetry Ping</p>
          </div>
        </div>
      </div>
    </div>
  );
}

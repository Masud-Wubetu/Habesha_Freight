import GoogleMapView from '../../components/GoogleMapView';
import PageHeader from '../../components/PageHeader';

export default function LiveTracking() {
  const origin = { lat: 9.0300, lng: 38.7400, label: 'Addis Ababa' };
  const destination = { lat: 9.6000, lng: 41.8600, label: 'Dire Dawa' };
  const driver = { lat: 8.9806, lng: 38.7578, label: 'Driver Truck' };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <PageHeader
        title="Live GPS Tracking"
        subtitle="Real-time location of your active delivery on Google Maps"
      />

      <div className="mt-6 mb-6">
        <GoogleMapView
          driverPos={driver}
          originPos={origin}
          destinationPos={destination}
          speed={68}
          height="450px"
        />
      </div>

      <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <h3 className="text-lg font-bold text-slate-900 mb-4">
          Telemetry & Route Overview
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block mb-1">Origin City</span>
            <span className="text-sm font-bold text-slate-900">Addis Ababa, Ethiopia</span>
          </div>
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block mb-1">Destination</span>
            <span className="text-sm font-bold text-slate-900">Dire Dawa, Ethiopia</span>
          </div>
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
            <span className="text-xs font-bold text-slate-400 uppercase tracking-wider block mb-1">Telemetry Status</span>
            <span className="text-sm font-bold text-emerald-600">Active · Signal Strong (GPS)</span>
          </div>
        </div>
      </div>
    </div>
  );
}

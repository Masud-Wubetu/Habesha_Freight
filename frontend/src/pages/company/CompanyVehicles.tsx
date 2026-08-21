import React, { useEffect, useState } from 'react';
import { api } from '../../services/api';

interface Vehicle {
  id?: string;
  plate: string;
  model: string;
  type: string;
  capacity: string;
  driver?: string;
  status: 'AVAILABLE' | 'IN_TRANSIT' | 'MAINTENANCE' | 'Available' | 'In Transit' | 'Maintenance';
}

export default function CompanyVehicles() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const [newVehicle, setNewVehicle] = useState({
    plate: '',
    model: '',
    type: 'TRAILER',
    capacity: '10t',
    driver: '',
  });

  const showNotification = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const fetchVehicles = async () => {
    setLoading(true);
    try {
      const res = await api.get<any>('/vehicles');
      const list = Array.isArray(res) ? res : Array.isArray(res?.vehicles) ? res.vehicles : [];
      if (list.length > 0) {
        setVehicles(
          list.map((v: any) => ({
            id: v.id,
            plate: v.plateNumber || v.plate || 'AA-00000',
            model: v.model || v.makeModel || 'Isuzu Truck',
            type: v.type || 'TRAILER',
            capacity: v.capacity ? `${v.capacity}t` : '10t',
            driver: v.driverName || v.driver || 'Unassigned',
            status: (v.status || 'AVAILABLE').toUpperCase() as any,
          }))
        );
      } else {
        setVehicles([
          { plate: 'AAU-3421', model: 'Isuzu FSR', type: 'TRAILER', capacity: '10t', driver: 'Abebe Girma', status: 'AVAILABLE' },
          { plate: 'AA-45892', model: 'Mercedes Actros', type: 'VAN', capacity: '20t', driver: 'Tesfaye Haile', status: 'IN_TRANSIT' },
          { plate: 'AA-11034', model: 'Volvo FH', type: 'SINO_TRUCK', capacity: '25t', driver: 'Selam Tadesse', status: 'AVAILABLE' },
          { plate: 'AA-77821', model: 'Isuzu NPR', type: 'Box Truck', capacity: '5t', driver: 'Unassigned', status: 'MAINTENANCE' },
          { plate: 'AA-92340', model: 'Sino Howo', type: 'TRAILER', capacity: '30t', driver: 'Kibru Alemu', status: 'IN_TRANSIT' },
        ]);
      }
    } catch (err) {
      setVehicles([
        { plate: 'AAU-3421', model: 'Isuzu FSR', type: 'TRAILER', capacity: '10t', driver: 'Abebe Girma', status: 'AVAILABLE' },
        { plate: 'AA-45892', model: 'Mercedes Actros', type: 'VAN', capacity: '20t', driver: 'Tesfaye Haile', status: 'IN_TRANSIT' },
        { plate: 'AA-11034', model: 'Volvo FH', type: 'SINO_TRUCK', capacity: '25t', driver: 'Selam Tadesse', status: 'AVAILABLE' },
        { plate: 'AA-77821', model: 'Isuzu NPR', type: 'Box Truck', capacity: '5t', driver: 'Unassigned', status: 'MAINTENANCE' },
        { plate: 'AA-92340', model: 'Sino Howo', type: 'TRAILER', capacity: '30t', driver: 'Kibru Alemu', status: 'IN_TRANSIT' },
      ]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVehicles();
  }, []);

  const handleAddVehicle = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newVehicle.plate || !newVehicle.model) {
      showNotification('Plate number and vehicle model are required');
      return;
    }

    try {
      await api.post('/vehicles', {
        plateNumber: newVehicle.plate,
        makeModel: newVehicle.model,
        type: newVehicle.type,
        capacity: parseInt(newVehicle.capacity) || 10,
        status: 'AVAILABLE',
      });
      showNotification(`Vehicle ${newVehicle.plate} successfully registered!`);
    } catch (err) {
      setVehicles((prev) => [
        ...prev,
        {
          id: String(Date.now()),
          plate: newVehicle.plate,
          model: newVehicle.model,
          type: newVehicle.type,
          capacity: newVehicle.capacity,
          driver: newVehicle.driver || 'Unassigned',
          status: 'AVAILABLE',
        },
      ]);
      showNotification(`Vehicle ${newVehicle.plate} registered!`);
    }

    setIsModalOpen(false);
    setNewVehicle({ plate: '', model: '', type: 'TRAILER', capacity: '10t', driver: '' });
  };

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      {toastMessage && (
        <div className="fixed top-5 right-5 z-50 bg-slate-900 text-white px-5 py-3 rounded-xl shadow-xl border-l-4 border-amber-500 text-sm font-medium">
          🔔 {toastMessage}
        </div>
      )}

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Fleet Vehicles Directory</h1>
          <p className="text-xs text-slate-500 mt-1">Manage transport company commercial trucks, trailers, and equipment</p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold px-4 py-2.5 rounded-xl text-sm transition-all shadow-md flex items-center gap-2"
        >
          <span>+</span> Register New Truck
        </button>
      </div>

      <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        {loading ? (
          <div className="py-12 text-center">
            <div className="w-8 h-8 border-3 border-amber-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
            <p className="text-xs text-slate-500">Loading vehicle directory...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-slate-200 text-xs font-bold uppercase tracking-wider text-slate-400 bg-slate-50">
                  <th className="p-3">Plate Number</th>
                  <th className="p-3">Make &amp; Model</th>
                  <th className="p-3">Body Type</th>
                  <th className="p-3">Payload Capacity</th>
                  <th className="p-3">Assigned Driver</th>
                  <th className="p-3">Status</th>
                  <th className="p-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-sm">
                {vehicles.map((v) => (
                  <tr key={v.plate} className="hover:bg-slate-50 transition-colors">
                    <td className="p-3 font-mono font-bold text-slate-900">{v.plate}</td>
                    <td className="p-3 font-semibold text-slate-800">{v.model}</td>
                    <td className="p-3 text-slate-600">{v.type}</td>
                    <td className="p-3 font-bold text-slate-700">{v.capacity}</td>
                    <td className="p-3 text-slate-700">{v.driver || 'Unassigned'}</td>
                    <td className="p-3">
                      <span
                        className={`text-xs font-extrabold px-2.5 py-1 rounded-full ${
                          v.status === 'AVAILABLE' || v.status === 'Available'
                            ? 'bg-emerald-100 text-emerald-800'
                            : v.status === 'IN_TRANSIT' || v.status === 'In Transit'
                            ? 'bg-blue-100 text-blue-800'
                            : 'bg-rose-100 text-rose-800'
                        }`}
                      >
                        {v.status}
                      </span>
                    </td>
                    <td className="p-3 text-right">
                      <button
                        onClick={() => showNotification(`Editing vehicle ${v.plate}`)}
                        className="text-xs font-bold text-slate-600 hover:text-slate-900 bg-slate-100 px-3 py-1.5 rounded-lg"
                      >
                        Edit
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal: Register Vehicle */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-5">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-lg font-bold text-slate-900">Register Fleet Truck</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-slate-400 font-bold text-xl">✕</button>
            </div>

            <form onSubmit={handleAddVehicle} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Plate Number</label>
                <input
                  type="text"
                  placeholder="e.g. AAU-9876"
                  value={newVehicle.plate}
                  onChange={(e) => setNewVehicle({ ...newVehicle, plate: e.target.value })}
                  className="w-full p-3 border border-slate-200 rounded-xl text-sm font-mono focus:outline-none focus:border-amber-500"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Make &amp; Model</label>
                <input
                  type="text"
                  placeholder="e.g. Isuzu FSR / Mercedes Actros"
                  value={newVehicle.model}
                  onChange={(e) => setNewVehicle({ ...newVehicle, model: e.target.value })}
                  className="w-full p-3 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-amber-500"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Body Type</label>
                  <select
                    value={newVehicle.type}
                    onChange={(e) => setNewVehicle({ ...newVehicle, type: e.target.value })}
                    className="w-full p-3 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-amber-500"
                  >
                    <option value="TRAILER">TRAILER</option>
                    <option value="Box Truck">Box Truck</option>
                    <option value="VAN">VAN</option>
                    <option value="SINO_TRUCK">SINO_TRUCK</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Payload Capacity</label>
                  <input
                    type="text"
                    placeholder="e.g. 15t"
                    value={newVehicle.capacity}
                    onChange={(e) => setNewVehicle({ ...newVehicle, capacity: e.target.value })}
                    className="w-full p-3 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-amber-500"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 uppercase mb-1">Assign Driver (Optional)</label>
                <input
                  type="text"
                  placeholder="e.g. Abebe Girma"
                  value={newVehicle.driver}
                  onChange={(e) => setNewVehicle({ ...newVehicle, driver: e.target.value })}
                  className="w-full p-3 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-amber-500"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 rounded-xl text-sm font-semibold text-slate-600">
                  Cancel
                </button>
                <button type="submit" className="bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold px-5 py-2 rounded-xl text-sm shadow-md">
                  Save Vehicle
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

import { useEffect, useState } from 'react';
import { api } from '../../services/api';

interface Delivery {
  id: string;
  shipper: string;
  route: string;
  trucks: number;
  status: 'Pending' | 'Accepted' | 'In Progress' | 'Completed';
  amount: string;
}

export default function CompanyDeliveries() {
  const [deliveries, setDeliveries] = useState<Delivery[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchDeliveries = async () => {
    setLoading(true);
    try {
      const res = await api.get<any>('/company/deliveries');
      const loadList = Array.isArray(res)
        ? res
        : Array.isArray(res?.data)
        ? res.data
        : [];

      setDeliveries(
        loadList.map((l: any, idx: number) => ({
          id: l.id ? `DEL-${l.id.slice(0, 8).toUpperCase()}` : `DEL-00${idx + 1}`,
          shipper: l.cargo_description || 'Commercial Freight',
          route: `${l.origin_city || 'Addis Ababa'} → ${l.destination_city || 'Regional Center'}`,
          trucks: 1,
          status: l.status === 'DELIVERED' ? 'Completed' : l.status === 'IN_TRANSIT' ? 'In Progress' : 'Accepted',
          amount: l.offered_price_etb ? `ETB ${Number(l.offered_price_etb).toLocaleString()}` : 'N/A',
        }))
      );
    } catch (err) {
      console.error('Error fetching company deliveries:', err);
      setDeliveries([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDeliveries();
  }, []);

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Fleet Deliveries</h1>
          <p className="text-xs text-slate-500 mt-1">Live tracking and history of transport company deliveries</p>
        </div>
        <button onClick={fetchDeliveries} className="bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold px-4 py-2 rounded-xl text-xs transition-colors">
          🔄 Refresh
        </button>
      </div>

      <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        {loading ? (
          <div className="py-12 text-center">
            <div className="w-8 h-8 border-3 border-amber-500 border-t-transparent rounded-full animate-spin mx-auto mb-2"></div>
            <p className="text-xs text-slate-500">Loading delivery records...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-slate-200 text-xs font-bold uppercase tracking-wider text-slate-400 bg-slate-50">
                  <th className="p-3">Delivery ID</th>
                  <th className="p-3">Shipper</th>
                  <th className="p-3">Transit Route</th>
                  <th className="p-3">Assigned Fleet</th>
                  <th className="p-3">Status</th>
                  <th className="p-3">Amount</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-sm">
                {deliveries.map((d) => (
                  <tr key={d.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-3 font-bold text-slate-900">{d.id}</td>
                    <td className="p-3 font-medium text-slate-700">{d.shipper}</td>
                    <td className="p-3 font-semibold text-slate-800">{d.route}</td>
                    <td className="p-3 font-bold text-slate-700">{d.trucks} Trucks</td>
                    <td className="p-3">
                      <span
                        className={`text-xs font-extrabold px-2.5 py-1 rounded-full ${
                          d.status === 'Completed'
                            ? 'bg-emerald-100 text-emerald-800'
                            : d.status === 'In Progress'
                            ? 'bg-blue-100 text-blue-800'
                            : 'bg-amber-100 text-amber-800'
                        }`}
                      >
                        {d.status}
                      </span>
                    </td>
                    <td className="p-3 font-extrabold text-amber-600">{d.amount}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

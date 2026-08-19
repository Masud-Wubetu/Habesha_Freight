import { useState } from 'react';

interface Driver {
  id: string;
  name: string;
  phone: string;
  licenseGrade: string;
  assignedVehicle: string;
  status: 'Available' | 'On Delivery' | 'Off Duty';
}

export default function CompanyDrivers() {
  const [drivers] = useState<Driver[]>([
    { id: 'D-1', name: 'Abebe Girma', phone: '+251 911 123 456', licenseGrade: 'Level 5 (Heavy Truck)', assignedVehicle: 'AAU-3421 (Isuzu FSR)', status: 'Available' },
    { id: 'D-2', name: 'Tesfaye Haile', phone: '+251 912 987 654', licenseGrade: 'Level 5 (Articulated)', assignedVehicle: 'AA-45892 (Mercedes Actros)', status: 'On Delivery' },
    { id: 'D-3', name: 'Selam Tadesse', phone: '+251 913 555 777', licenseGrade: 'Level 4 (Medium Truck)', assignedVehicle: 'AA-11034 (Volvo FH)', status: 'Available' },
    { id: 'D-4', name: 'Kibru Alemu', phone: '+251 914 333 111', licenseGrade: 'Level 5 (Heavy Trailer)', assignedVehicle: 'AA-92340 (Sino Howo)', status: 'On Delivery' },
  ]);

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Company Drivers Directory</h1>
          <p className="text-xs text-slate-500 mt-1">Licensed heavy truck operators registered under your fleet company</p>
        </div>
      </div>

      <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-slate-200 text-xs font-bold uppercase tracking-wider text-slate-400 bg-slate-50">
                <th className="p-3">Driver Name</th>
                <th className="p-3">Phone Number</th>
                <th className="p-3">License Grade</th>
                <th className="p-3">Assigned Vehicle</th>
                <th className="p-3">Duty Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-sm">
              {drivers.map((d) => (
                <tr key={d.id} className="hover:bg-slate-50 transition-colors">
                  <td className="p-3 font-bold text-slate-900">{d.name}</td>
                  <td className="p-3 font-mono text-slate-600">{d.phone}</td>
                  <td className="p-3 text-slate-700 font-medium">{d.licenseGrade}</td>
                  <td className="p-3 font-semibold text-slate-800">{d.assignedVehicle}</td>
                  <td className="p-3">
                    <span
                      className={`text-xs font-extrabold px-2.5 py-1 rounded-full ${
                        d.status === 'Available' ? 'bg-emerald-100 text-emerald-800' : 'bg-blue-100 text-blue-800'
                      }`}
                    >
                      {d.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

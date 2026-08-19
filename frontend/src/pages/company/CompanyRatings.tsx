export default function CompanyRatings() {
  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <h1 className="text-2xl font-bold text-slate-900">Company Ratings &amp; Reviews</h1>
        <p className="text-xs text-slate-500 mt-1">Track shipper evaluations and delivery service performance</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div className="text-center sm:text-left border-b sm:border-b-0 sm:border-r border-slate-100 pb-4 sm:pb-0 sm:pr-4">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Overall Rating</p>
          <p className="text-4xl font-extrabold text-slate-900 mt-1">4.9 / 5.0</p>
          <p className="text-xs text-emerald-600 font-semibold mt-1">★★★★★ (124 Verified Shipments)</p>
        </div>

        <div className="text-center sm:text-left border-b sm:border-b-0 sm:border-r border-slate-100 pb-4 sm:pb-0 sm:pr-4">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">On-Time Delivery Rate</p>
          <p className="text-4xl font-extrabold text-emerald-600 mt-1">98.4%</p>
          <p className="text-xs text-slate-500 mt-1">Cargo corridor schedule adherence</p>
        </div>

        <div className="text-center sm:text-left">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-wider">Cargo Safety Record</p>
          <p className="text-4xl font-extrabold text-blue-600 mt-1">100%</p>
          <p className="text-xs text-slate-500 mt-1">Zero insurance damage claims reported</p>
        </div>
      </div>
    </div>
  );
}

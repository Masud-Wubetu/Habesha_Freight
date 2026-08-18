import './Deliveries.css';

interface Delivery {
  id: string;
  shipper: string;
  route: string;
  trucks: number;
  status: 'Pending' | 'Accepted' | 'In Progress' | 'Completed';
  amount: string;
}

const deliveries: Delivery[] = [
  {
    id: 'FR-001',
    shipper: 'Tigist Worku',
    route: 'Addis Ababa → Dire Dawa',
    trucks: 3,
    status: 'Pending',
    amount: 'ETB 42,000',
  },
  {
    id: 'FR-002',
    shipper: 'Yohannes Alemu',
    route: 'Adama → Hawassa',
    trucks: 2,
    status: 'Accepted',
    amount: 'ETB 28,500',
  },
  {
    id: 'FR-003',
    shipper: 'Sara Bekele',
    route: 'Addis → Mekelle',
    trucks: 5,
    status: 'In Progress',
    amount: 'ETB 75,000',
  },
  {
    id: 'FR-004',
    shipper: 'Dawit Haile',
    route: 'Bahir Dar → Addis',
    trucks: 1,
    status: 'Completed',
    amount: 'ETB 14,200',
  },
];

const statusClass = {
  Pending: 'delivery-status pending',
  Accepted: 'delivery-status accepted',
  'In Progress': 'delivery-status progress',
  Completed: 'delivery-status completed',
};

export default function Deliveries() {
  return (
    <div className="deliveries-page">
      <div className="deliveries-card">
        <h2>Company Deliveries</h2>

        <div className="deliveries-table-wrapper">
          <table className="deliveries-table">
            <thead>
              <tr>
                <th>Request ID</th>
                <th>Shipper</th>
                <th>Route</th>
                <th>Trucks</th>
                <th>Status</th>
                <th>Amount</th>
                <th>Actions</th>
              </tr>
            </thead>

            <tbody>
              {deliveries.map((delivery) => (
                <tr key={delivery.id}>
                  <td>{delivery.id}</td>
                  <td>{delivery.shipper}</td>
                  <td>{delivery.route}</td>
                  <td>{delivery.trucks}</td>

                  <td>
                    <span className={statusClass[delivery.status]}>
                      {delivery.status}
                    </span>
                  </td>

                  <td className="delivery-amount">
                    {delivery.amount}
                  </td>

                  <td>
                    <button className="delivery-view">
                      View
                    </button>
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
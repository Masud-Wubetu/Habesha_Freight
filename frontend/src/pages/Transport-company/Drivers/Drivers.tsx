import React from 'react';
import './Drivers.css';

interface Driver {
  name: string;
  phone: string;
  license: string;
  trips: number;
  rating: number;
  status: 'Active' | 'On Delivery';
}

const drivers: Driver[] = [
  {
    name: 'Abebe Girma',
    phone: '+251 912 345 678',
    license: 'DL-AAA-00123',
    trips: 48,
    rating: 4.8,
    status: 'Active',
  },
  {
    name: 'Tesfaye Haile',
    phone: '+251 913 456 789',
    license: 'DL-AAA-00456',
    trips: 32,
    rating: 4.5,
    status: 'On Delivery',
  },
  {
    name: 'Selam Tadesse',
    phone: '+251 914 567 890',
    license: 'DL-AAA-00789',
    trips: 21,
    rating: 4.7,
    status: 'Active',
  },
  {
    name: 'Kibru Alemu',
    phone: '+251 915 678 901',
    license: 'DL-AAA-01012',
    trips: 14,
    rating: 4.6,
    status: 'On Delivery',
  },
];

const Drivers: React.FC = () => {
  return (
    <div className="drivers-page">

      <div className="drivers-card">

        {/* Header */}
        <div className="drivers-header">
          <h2>Company Drivers</h2>

          <div className="add-driver-btn">
            <button type="button">
              + Add Driver
            </button>
          </div>
        </div>

        {/* Table */}
        <div className="drivers-table-wrapper">
          <table className="drivers-table">

            <thead>
              <tr>
                <th>Name</th>
                <th>Phone</th>
                <th>License</th>
                <th>Trips</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>

            <tbody>
              {drivers.map((driver) => (
                <tr key={driver.license}>

                  <td className="driver-name">
                    {driver.name}
                  </td>

                  <td>
                    {driver.phone}
                  </td>

                  <td className="driver-license">
                    {driver.license}
                  </td>

                  <td>
                    {driver.trips}
                  </td>

                  <td>
                    <span className="driver-rating">
                      <span className="rating-star">★</span>
                      {driver.rating}
                    </span>
                  </td>

                  <td>
                    <span
                      className={`driver-status ${
                        driver.status === 'Active'
                          ? 'active'
                          : 'delivery'
                      }`}
                    >
                      {driver.status}
                    </span>
                  </td>

                  <td>
                    <div className="driver-actions">
                      <button
                        type="button"
                        className="view"
                      >
                        View
                      </button>

                      <button
                        type="button"
                        className="assign"
                      >
                        Assign
                      </button>
                    </div>
                  </td>

                </tr>
              ))}
            </tbody>

          </table>
        </div>

      </div>

    </div>
  );
};

export default Drivers;
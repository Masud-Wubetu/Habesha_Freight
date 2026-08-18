import React from 'react';
import './Vehicles.css';

interface Vehicle {
  plate: string;
  model: string;
  type: string;
  capacity: string;
  driver: string;
  status: 'Available' | 'In Transit' | 'Maintenance';
}

const vehicles: Vehicle[] = [
  {
    plate: 'AAU-3421',
    model: 'Isuzu FSR',
    type: 'Flatbed',
    capacity: '10t',
    driver: 'Abebe Girma',
    status: 'Available',
  },
  {
    plate: 'AA-45892',
    model: 'Mercedes Actros',
    type: 'Refrigerated',
    capacity: '20t',
    driver: 'Tesfaye Haile',
    status: 'In Transit',
  },
  {
    plate: 'AA-11034',
    model: 'Volvo FH',
    type: 'Tanker',
    capacity: '25t',
    driver: 'Selam Tadesse',
    status: 'Available',
  },
  {
    plate: 'AA-77821',
    model: 'Isuzu NPR',
    type: 'Box Truck',
    capacity: '5t',
    driver: 'Unassigned',
    status: 'Maintenance',
  },
  {
    plate: 'AA-92340',
    model: 'Sino Howo',
    type: 'Flatbed',
    capacity: '30t',
    driver: 'Kibru Alemu',
    status: 'In Transit',
  },
];

const Vehicles: React.FC = () => {
  const getStatusClass = (status: Vehicle['status']) => {
    switch (status) {
      case 'Available':
        return 'available';
      case 'In Transit':
        return 'transit';
      case 'Maintenance':
        return 'maintenance';
      default:
        return '';
    }
  };

  return (
    <div className="vehicles-page">

    

      {/* Vehicles Card */}
      <div className="vehicles-card">

      <div className="vehicles-header">
  <h2>Fleet Vehicles</h2>

  <div className="add-vehicle-btn">
    <button type="button">
      + Add Vehicle
    </button>
  </div>
</div>
        <div className="vehicles-table-wrapper">
          <table className="vehicles-table">

            <thead>
              <tr>
                <th>Plate</th>
                <th>Model</th>
                <th>Type</th>
                <th>Capacity</th>
                <th>Driver</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>

            <tbody>
              {vehicles.map((vehicle) => (
                <tr key={vehicle.plate}>

                  <td>
                    <span className="vehicle-plate">
                      {vehicle.plate}
                    </span>
                  </td>

                  <td>{vehicle.model}</td>

                  <td>{vehicle.type}</td>

                  <td>{vehicle.capacity}</td>

                  <td>
                    {vehicle.driver === 'Unassigned' ? (
                      <span style={{ color: '#ff6b00' }}>
                        Unassigned
                      </span>
                    ) : (
                      vehicle.driver
                    )}
                  </td>

                  <td>
                    <span
                      className={`vehicle-status ${getStatusClass(
                        vehicle.status
                      )}`}
                    >
                      {vehicle.status}
                    </span>
                  </td>

                  <td>
                    <div className="vehicle-actions">

                      <button
                        type="button"
                        className="edit"
                      >
                        Edit
                      </button>

                      <button
                        type="button"
                        className="assign"
                      >
                        Assign
                      </button>

                      <button
                        type="button"
                        className="deactivate"
                      >
                        Deactivate
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

export default Vehicles;
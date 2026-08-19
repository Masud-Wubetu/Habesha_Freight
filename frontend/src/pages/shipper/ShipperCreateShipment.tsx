import { useState } from 'react';
import { useNavigate } from 'react-router-dom';

interface FormData {
  origin: string;
  destination: string;
  cargoType: string;
  weight: string;
  quantity: string;
  vehicleType: string;
  pickupDate: string;
  pickupTime: string;
  deliveryDate: string;
  deliveryTime: string;
  notes: string;
}

export default function CreateShipment() {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [formData, setFormData] = useState<FormData>({
    origin: '',
    destination: '',
    cargoType: '',
    weight: '',
    quantity: '',
    vehicleType: '',
    pickupDate: '',
    pickupTime: '',
    deliveryDate: '',
    deliveryTime: '',
    notes: '',
  });

  const cargoTypes = ['General Cargo', 'Perishable', 'Fragile', 'Hazardous', 'Livestock', 'Oversized'];
  const vehicleTypes = ['Truck', 'Trailer', 'Container', 'Flatbed', 'Refrigerated', 'Tanker'];

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors((prev) => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  const validate = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.origin.trim()) newErrors.origin = 'Origin is required';
    if (!formData.destination.trim()) newErrors.destination = 'Destination is required';
    if (!formData.cargoType) newErrors.cargoType = 'Cargo type is required';
    if (!formData.weight.trim()) newErrors.weight = 'Weight is required';
    if (!formData.quantity.trim()) newErrors.quantity = 'Quantity is required';
    if (!formData.vehicleType) newErrors.vehicleType = 'Vehicle type is required';
    if (!formData.pickupDate) newErrors.pickupDate = 'Pickup date is required';
    if (!formData.pickupTime) newErrors.pickupTime = 'Pickup time is required';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validate()) {
      return;
    }

    setIsSubmitting(true);

    setTimeout(() => {
      console.log('Shipment data:', formData);
      setIsSubmitting(false);
      setSubmitSuccess(true);
      
      setTimeout(() => {
        navigate('/dashboard');
      }, 2000);
    }, 1500);
  };

  if (submitSuccess) {
    return (
      <div className="create-shipment-container">
        <div className="create-shipment-card">
          <div className="success-content">
            <span className="success-icon">✅</span>
            <h2 className="success-title">Shipment Posted Successfully!</h2>
            <p className="success-message">
              Your shipment has been posted and is now visible to carriers.
              You will receive bids shortly.
            </p>
            <button
              onClick={() => navigate('/dashboard')}
              className="register-next-btn"
              style={{ width: 'auto', padding: '0.75rem 2rem' }}
            >
              Go to Dashboard
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="create-shipment-container">
      <div className="create-shipment-card">
        <div className="create-shipment-header">
          <h1 className="create-shipment-title">📦 Post a Shipment</h1>
          <p className="create-shipment-subtitle">
            Fill in the details below to post your shipment and receive bids from carriers.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="create-shipment-form">
          {/* Route Information */}
          <div className="form-section">
            <h3 className="form-section-title">Route Information</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label>Origin <span className="required">*</span></label>
                <input
                  type="text"
                  name="origin"
                  value={formData.origin}
                  onChange={handleChange}
                  placeholder="e.g., Addis Ababa"
                  className={`form-input ${errors.origin ? 'input-error' : ''}`}
                />
                {errors.origin && <span className="input-error-text">{errors.origin}</span>}
              </div>

              <div className="form-group">
                <label>Destination <span className="required">*</span></label>
                <input
                  type="text"
                  name="destination"
                  value={formData.destination}
                  onChange={handleChange}
                  placeholder="e.g., Adama"
                  className={`form-input ${errors.destination ? 'input-error' : ''}`}
                />
                {errors.destination && <span className="input-error-text">{errors.destination}</span>}
              </div>
            </div>
          </div>

          {/* Cargo Information */}
          <div className="form-section">
            <h3 className="form-section-title">Cargo Information</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label>Cargo Type <span className="required">*</span></label>
                <select
                  name="cargoType"
                  value={formData.cargoType}
                  onChange={handleChange}
                  className={`form-input ${errors.cargoType ? 'input-error' : ''}`}
                >
                  <option value="">Select cargo type</option>
                  {cargoTypes.map((type) => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
                {errors.cargoType && <span className="input-error-text">{errors.cargoType}</span>}
              </div>

              <div className="form-group">
                <label>Weight (kg) <span className="required">*</span></label>
                <input
                  type="number"
                  name="weight"
                  value={formData.weight}
                  onChange={handleChange}
                  placeholder="e.g., 5000"
                  className={`form-input ${errors.weight ? 'input-error' : ''}`}
                />
                {errors.weight && <span className="input-error-text">{errors.weight}</span>}
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Quantity <span className="required">*</span></label>
                <input
                  type="number"
                  name="quantity"
                  value={formData.quantity}
                  onChange={handleChange}
                  placeholder="e.g., 10"
                  className={`form-input ${errors.quantity ? 'input-error' : ''}`}
                />
                {errors.quantity && <span className="input-error-text">{errors.quantity}</span>}
              </div>

              <div className="form-group">
                <label>Vehicle Type <span className="required">*</span></label>
                <select
                  name="vehicleType"
                  value={formData.vehicleType}
                  onChange={handleChange}
                  className={`form-input ${errors.vehicleType ? 'input-error' : ''}`}
                >
                  <option value="">Select vehicle type</option>
                  {vehicleTypes.map((type) => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
                {errors.vehicleType && <span className="input-error-text">{errors.vehicleType}</span>}
              </div>
            </div>
          </div>

          {/* Pickup & Delivery */}
          <div className="form-section">
            <h3 className="form-section-title">Pickup & Delivery</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label>Pickup Date <span className="required">*</span></label>
                <input
                  type="date"
                  name="pickupDate"
                  value={formData.pickupDate}
                  onChange={handleChange}
                  className={`form-input ${errors.pickupDate ? 'input-error' : ''}`}
                />
                {errors.pickupDate && <span className="input-error-text">{errors.pickupDate}</span>}
              </div>

              <div className="form-group">
                <label>Pickup Time <span className="required">*</span></label>
                <input
                  type="time"
                  name="pickupTime"
                  value={formData.pickupTime}
                  onChange={handleChange}
                  className={`form-input ${errors.pickupTime ? 'input-error' : ''}`}
                />
                {errors.pickupTime && <span className="input-error-text">{errors.pickupTime}</span>}
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Delivery Date</label>
                <input
                  type="date"
                  name="deliveryDate"
                  value={formData.deliveryDate}
                  onChange={handleChange}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label>Delivery Time</label>
                <input
                  type="time"
                  name="deliveryTime"
                  value={formData.deliveryTime}
                  onChange={handleChange}
                  className="form-input"
                />
              </div>
            </div>
          </div>

          {/* Additional Notes */}
          <div className="form-section">
            <h3 className="form-section-title">Additional Information</h3>
            
            <div className="form-group">
              <label>Notes / Special Instructions</label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                placeholder="Any special instructions for the carrier..."
                className="form-input form-textarea"
                rows={4}
              />
            </div>
          </div>

          {/* Actions */}
          <div className="create-shipment-actions">
            <button
              type="button"
              onClick={() => navigate('/dashboard')}
              className="create-shipment-cancel-btn"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="create-shipment-submit-btn"
            >
              {isSubmitting ? 'Posting...' : 'Post Shipment'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
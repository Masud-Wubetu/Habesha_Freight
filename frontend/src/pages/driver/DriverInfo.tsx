import React, { useState, useEffect } from 'react';

import { fetchCurrentUser } from '../../services/authService';
import LoadingState from '../../components/LoadingState';
import ErrorState from '../../components/ErrorState';
import '../../styles/driver-profile.css';

// Extended driver profile data interface
interface DriverProfileData {
  name: string;
  rating: number;
  trips: number;
  phone: string;
  truckModel: string;
  plateNumber: string;
  capacity: string;
  truckType: string;
  licenseNumber: string;
  serviceArea: string;
  isVerified: boolean;
  isOnline: boolean;
  initials: string;
}

const DriverInfo: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [profileData, setProfileData] = useState<DriverProfileData>({
    name: 'Abebe Girma',
    rating: 4.8,
    trips: 142,
    phone: '+251 912 345 678',
    truckModel: 'Isuzu FSR 2019',
    plateNumber: 'AAU-3421',
    capacity: '10 tons',
    truckType: 'Flatbed',
    licenseNumber: 'DL-2891047',
    serviceArea: 'All Ethiopia',
    isVerified: true,
    isOnline: true,
    initials: 'AG',
  });

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      setLoading(true);

      const user = await fetchCurrentUser();

      if (user) {
        const userName =
          (user as any).name ||
          (user as any).fullName ||
          'Abebe Girma';

        const nameParts = userName.split(' ');

        const initials =
          nameParts.length > 1
            ? `${nameParts[0][0]}${nameParts[1][0]}`.toUpperCase()
            : userName.substring(0, 2).toUpperCase();

        const userPhone =
          (user as any).phone ||
          (user as any).phoneNumber ||
          (user as any).mobile ||
          (user as any).telephone ||
          '+251 912 345 678';

        setProfileData((prev) => ({
          ...prev,
          name: userName,
          initials,
          phone: userPhone,

          ...((user as any).truckModel && {
            truckModel: (user as any).truckModel,
          }),

          ...((user as any).plateNumber && {
            plateNumber: (user as any).plateNumber,
          }),

          ...((user as any).capacity && {
            capacity: (user as any).capacity,
          }),

          ...((user as any).truckType && {
            truckType: (user as any).truckType,
          }),

          ...((user as any).licenseNumber && {
            licenseNumber: (user as any).licenseNumber,
          }),

          ...((user as any).serviceArea && {
            serviceArea: (user as any).serviceArea,
          }),

          ...((user as any).rating && {
            rating: (user as any).rating,
          }),

          ...((user as any).trips !== undefined && {
            trips: (user as any).trips,
          }),

          ...((user as any).isVerified !== undefined && {
            isVerified: (user as any).isVerified,
          }),
        }));
      }

      setError(null);
    } catch (err) {
      console.error(
        'Error loading profile, falling back to mock data:',
        err
      );

      // Keep the default profile data visible
      setError(null);
    } finally {
      setLoading(false);
    }
  };

  const handleUploadPhoto = () => {
    const fileInput = document.createElement('input');

    fileInput.type = 'file';
    fileInput.accept = 'image/*';

    fileInput.onchange = (e) => {
      const target = e.target as HTMLInputElement;

      if (target.files && target.files[0]) {
        console.log(
          'File selected:',
          target.files[0].name
        );

        alert(
          `Photo "${target.files[0].name}" selected for upload`
        );
      }
    };

    fileInput.click();
  };

  const handleEditProfile = () => {
    console.log('Edit profile clicked');

    alert(
      'Edit Profile functionality - This would open the profile edit form'
    );
  };

  const toggleOnlineStatus = () => {
    setProfileData((prev) => ({
      ...prev,
      isOnline: !prev.isOnline,
    }));
  };

  if (loading) {
    return (
      <div className="driver-profile-container">
        <LoadingState />
      </div>
    );
  }

  if (error) {
    return (
      <div className="driver-profile-container">
        <ErrorState message={error} />
      </div>
    );
  }

  return (
    <div className="driver-profile-container">

      {/* Page Header */}
      <div className="profile-page-header">

        <div className="profile-header-left">
          <h1 className="profile-page-title">
            Profile
          </h1>

          <p className="profile-page-date">
            {new Date().toLocaleDateString('en-US', {
              weekday: 'long',
              year: 'numeric',
              month: 'short',
              day: 'numeric',
            })}
          </p>
        </div>

        <div className="profile-header-right">

          <div className="status-pill">
            <span className="status-dot"></span>

            {profileData.isOnline
              ? 'Online & Available'
              : 'Offline'}
          </div>

          <button
            className="status-toggle-btn"
            onClick={toggleOnlineStatus}
            title="Toggle online status"
          >
            {profileData.isOnline ? '🌙' : '☀️'}
          </button>

          <div className="header-avatar">
            {profileData.initials}
          </div>

        </div>
      </div>

      {/* Profile Card */}
      <div className="profile-card">

        {/* Profile Introduction */}
        <div className="profile-intro">

          <div className="profile-avatar">
            {profileData.initials}
          </div>

          <div className="profile-info">

            <h2 className="profile-name">
              {profileData.name}
            </h2>

            <div className="profile-meta">

              <span className="profile-rating">
                <span className="star-icon">
                  ⭐
                </span>

                {profileData.rating.toFixed(1)}
              </span>

              <span className="profile-trips">
                · {profileData.trips} trips
              </span>

              {profileData.isVerified && (
                <span className="verified-badge">
                  ✓ Verified
                </span>
              )}

            </div>

            <p className="profile-phone">
              {profileData.phone}
            </p>

            <button
              className="upload-photo-btn"
              onClick={handleUploadPhoto}
            >
              Upload Photo
            </button>

          </div>
        </div>

        {/* Profile Details */}
        <div className="profile-details">

          <div className="detail-row">
            <span className="detail-label">
              Truck Model
            </span>

            <span className="detail-value">
              {profileData.truckModel}
            </span>
          </div>

          <div className="detail-row">
            <span className="detail-label">
              Plate Number
            </span>

            <span className="detail-value">
              {profileData.plateNumber}
            </span>
          </div>

          <div className="detail-row">
            <span className="detail-label">
              Capacity
            </span>

            <span className="detail-value">
              {profileData.capacity}
            </span>
          </div>

          <div className="detail-row">
            <span className="detail-label">
              Truck Type
            </span>

            <span className="detail-value">
              {profileData.truckType}
            </span>
          </div>

          <div className="detail-row">
            <span className="detail-label">
              License Number
            </span>

            <span className="detail-value">
              {profileData.licenseNumber}
            </span>
          </div>

          <div className="detail-row">
            <span className="detail-label">
              Service Area
            </span>

            <span className="detail-value">
              {profileData.serviceArea}
            </span>
          </div>

        </div>

        {/* Edit Profile Button */}
        <button
          className="edit-profile-btn"
          onClick={handleEditProfile}
        >
          Edit Profile
        </button>

      </div>
    </div>
  );
};

export default DriverInfo;
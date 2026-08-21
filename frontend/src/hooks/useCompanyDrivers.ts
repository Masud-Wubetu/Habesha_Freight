import { useEffect, useState, useCallback } from 'react';
import { get } from '../services/api';

export interface Driver {
  id: string;
  name: string;
  phone: string;
  licenseGrade: string;
  assignedVehicle: string;
  status: 'Available' | 'On Delivery' | 'Off Duty';
}

export function useCompanyDrivers(_companyId?: string) {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDrivers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await get<any>('/company/drivers');
      const list: any[] = Array.isArray(data) ? data : data?.drivers ?? data?.data ?? [];
      const mapped: Driver[] = list.map((d: any) => ({
        id: d.id || d.driver_id || '',
        name: d.full_name || d.name || 'Verified Driver',
        phone: d.phone_number || d.phone || 'N/A',
        licenseGrade: d.license_grade || d.licenseGrade || 'Heavy Freight Grade',
        assignedVehicle: d.assigned_vehicle || d.assignedVehicle || 'Unassigned',
        status: d.status === 'ACTIVE' ? 'Available' : 'Off Duty',
      }));
      setDrivers(mapped);
    } catch (e: any) {
      console.error('Failed to fetch company drivers', e);
      setError('Unable to load driver data');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDrivers();
  }, [fetchDrivers]);

  return { drivers, loading, error, refresh: fetchDrivers };
}

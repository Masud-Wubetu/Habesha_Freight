import { useEffect, useState, useCallback } from 'react';
import { api } from '../services/api';

export interface Driver {
  id: string;
  name: string;
  phone: string;
  licenseGrade: string;
  assignedVehicle: string;
  status: 'Available' | 'On Delivery' | 'Off Duty';
}

export function useCompanyDrivers(companyId: string) {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDrivers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.get<any>(`/companies/${companyId}/drivers`);
      // Assume backend returns { drivers: [] }
      const list = data?.drivers || [];
      const mapped: Driver[] = list.map((d: any) => ({
        id: d.id ?? '',
        name: d.full_name || d.name || '',
        phone: d.phone_number || d.phone || '',
        licenseGrade: d.license_grade || d.licenseGrade || '',
        assignedVehicle: d.assigned_vehicle || d.assignedVehicle || '',
        status: d.status as Driver['status'] || 'Available',
      }));
      setDrivers(mapped);
    } catch (e) {
      console.error('Failed to fetch company drivers', e);
      setError('Unable to load driver data');
    } finally {
      setLoading(false);
    }
  }, [companyId]);

  useEffect(() => {
    if (companyId) fetchDrivers();
  }, [companyId, fetchDrivers]);

  return { drivers, loading, error, refresh: fetchDrivers };
}

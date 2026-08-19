import { useEffect, useState, useCallback } from 'react';
import { api } from '../services/api';

export interface Vehicle {
  id?: string;
  plate: string;
  model: string;
  type: string;
  capacity: string;
  driver?: string;
  status: 'AVAILABLE' | 'IN_TRANSIT' | 'MAINTENANCE' | 'Available' | 'In Transit' | 'Maintenance';
}

export interface FleetRequest {
  id: string;
  customer: string;
  date: string;
  from: string;
  to: string;
  cargo: string;
  trucks: number;
  amount: string;
  status: 'Pending' | 'Accepted' | 'In Progress' | 'Completed' | 'Declined';
}

interface CompanyDataHook {
  companyName: string;
  vehicles: Vehicle[];
  requests: FleetRequest[];
  loading: boolean;
  refresh: () => void;
}

export function useCompanyData(): CompanyDataHook {
  const [companyName, setCompanyName] = useState('');
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [requests, setRequests] = useState<FleetRequest[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      // profile
      const profile = await api.get<any>('/auth/me');
      setCompanyName(profile?.fullName || profile?.companyName || '');

      // vehicles
      const vehRes = await api.get<any>('/vehicles');
      const vehList = Array.isArray(vehRes) ? vehRes : vehRes?.vehicles || [];
      setVehicles(
        vehList.map((v: any) => ({
          id: v.id,
          plate: v.plateNumber || v.plate || '-',
          model: v.model || v.makeModel || '-',
          type: v.type || '-',
          capacity: v.capacity ? `${v.capacity}t` : '-',
          driver: v.driverName || v.driver || 'Unassigned',
          status: (v.status || 'AVAILABLE').toUpperCase() as any,
        }))
      );

      // loads / requests
      const loadsRes = await api.get<any>('/loads');
      const loadList = Array.isArray(loadsRes) ? loadsRes : loadsRes?.loads || [];
      setRequests(
        loadList.map((l: any, idx: number) => ({
          id: l.id || `FR-00${idx + 1}`,
          customer: l.shipperName || 'Commercial Shipper',
          date: new Date(l.createdAt || Date.now()).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
          }),
          from: l.origin || '-',
          to: l.destination || '-',
          cargo: l.cargoType || '-',
          trucks: l.trucksNeeded || 0,
          amount: l.budget ? `ETB ${Number(l.budget).toLocaleString()}` : '-',
          status:
            l.status === 'ASSIGNED'
              ? 'Accepted'
              : l.status === 'IN_TRANSIT'
              ? 'In Progress'
              : 'Pending',
        }))
      );
    } catch (e) {
      console.error('Company data fetch error', e);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { companyName, vehicles, requests, loading, refresh: fetchData };
}

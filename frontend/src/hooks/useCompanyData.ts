import { useEffect, useState, useCallback } from 'react';
import { get } from '../services/api';

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
      // profile → GET /api/auth/me
      const profile = await get<any>('/auth/me');
      setCompanyName(profile?.full_name || '');

      // vehicles → GET /api/vehicles
      const vehData = await get<any>('/vehicles');
      const vehList = Array.isArray(vehData) ? vehData : vehData?.vehicles || vehData?.data || [];
      setVehicles(
        vehList.map((v: any) => ({
          id: v.id,
          plate: v.plate_number || v.plateNumber || v.plate || '-',
          model: v.model || v.make_model || v.makeModel || '-',
          type: v.type || '-',
          capacity: v.capacity_tons ? `${v.capacity_tons}t` : v.capacity ? `${v.capacity}t` : '-',
          driver: v.driverName || v.driver || 'Unassigned',
          status: (v.status || 'AVAILABLE').toUpperCase() as any,
        }))
      );

      // loads / requests → GET /api/loads (filtered to FLEET_OWNER context)
      const loadsData = await get<any>('/loads');
      const loadList = Array.isArray(loadsData) ? loadsData : loadsData?.data || loadsData?.loads || [];
      setRequests(
        loadList.map((l: any, idx: number) => ({
          id: l.id || `FR-00${idx + 1}`,
          customer: l.shipper_name || l.shipperName || 'Commercial Shipper',
          date: new Date(l.created_at || l.createdAt || Date.now()).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
          }),
          from: l.origin_city || l.origin || '-',
          to: l.destination_city || l.destination || '-',
          cargo: l.cargo_description || l.cargoType || '-',
          trucks: l.trucksNeeded || 0,
          amount: l.offered_price_etb
            ? `ETB ${Number(l.offered_price_etb).toLocaleString()}`
            : l.budget
            ? `ETB ${Number(l.budget).toLocaleString()}`
            : '-',
          status:
            l.status === 'MATCHED' || l.status === 'ASSIGNED'
              ? 'Accepted'
              : l.status === 'IN_TRANSIT'
              ? 'In Progress'
              : l.status === 'DELIVERED'
              ? 'Completed'
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

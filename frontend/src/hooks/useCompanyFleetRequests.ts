import { useEffect, useState, useCallback } from 'react';
import { api } from '../services/api';

interface FleetRequest {
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

export function useCompanyFleetRequests() {
  const [requests, setRequests] = useState<FleetRequest[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchRequests = useCallback(async () => {
    setLoading(true);
    try {
      const loadsRes = await api.get<any>('/loads');
      const loadList = Array.isArray(loadsRes) ? loadsRes : loadsRes?.loads || [];
      const mapped = loadList.map((l: any, idx: number) => ({
        id: l.id || `FR-00${idx + 1}`,
        customer: l.shipperName || 'Commercial Shipper',
        date: new Date(l.createdAt || Date.now()).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
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
            : l.status === 'COMPLETED'
            ? 'Completed'
            : l.status === 'DECLINED'
            ? 'Declined'
            : 'Pending',
      }));
      setRequests(mapped);
    } catch (e) {
      console.error('Failed to fetch fleet requests', e);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchRequests();
  }, [fetchRequests]);

  return { requests, loading, refresh: fetchRequests };
}

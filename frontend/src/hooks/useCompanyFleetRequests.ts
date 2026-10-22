import { useEffect, useState, useCallback } from 'react';
import { api } from '../services/api';

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

export function useCompanyFleetRequests() {
  const [requests, setRequests] = useState<FleetRequest[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchRequests = useCallback(async () => {
    setLoading(true);
    try {
      let loadsRes: any;
      try {
        loadsRes = await api.get<any>('/company/fleet-requests');
      } catch {
        loadsRes = await api.get<any>('/loads');
      }
      const loadList = Array.isArray(loadsRes)
        ? loadsRes
        : Array.isArray(loadsRes?.data)
        ? loadsRes.data
        : Array.isArray(loadsRes?.loads)
        ? loadsRes.loads
        : [];

      const mapped = loadList.map((l: any, idx: number) => ({
        id: String(l.id || `FR-00${idx + 1}`),
        customer: l.shipper_name || l.shipperName || 'Shipper',
        date: new Date(l.created_at || l.createdAt || Date.now()).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        from: l.origin_city || l.origin || '—',
        to: l.destination_city || l.destination || '—',
        cargo: l.cargo_description || l.cargoType || 'General Freight',
        trucks: l.weight_tons ? Math.ceil(Number(l.weight_tons) / 10) : l.trucksNeeded || 1,
        amount: l.offered_price_etb
          ? `ETB ${Number(l.offered_price_etb).toLocaleString()}`
          : l.budget
            ? `ETB ${Number(l.budget).toLocaleString()}`
            : '—',
        status:
          l.status === 'MATCHED' || l.status === 'ASSIGNED' || l.status === 'DISPATCHED'
            ? 'Accepted'
            : l.status === 'IN_TRANSIT'
              ? 'In Progress'
              : l.status === 'COMPLETED' || l.status === 'DELIVERED'
                ? 'Completed'
                : l.status === 'CANCELLED' || l.status === 'DECLINED'
                  ? 'Declined'
                  : 'Pending',
      })) as FleetRequest[];
      setRequests(mapped);
    } catch (e) {
      console.error('Failed to fetch company fleet requests', e);
      setRequests([]);
    } finally {
      setLoading(false);
    }
  }, []);

  const updateRequestStatus = async (id: string, newStatus: 'Accepted' | 'Declined') => {
    try {
      const endpoint = newStatus === 'Accepted' ? `/company/fleet-requests/${id}/accept` : `/company/fleet-requests/${id}/decline`;
      await api.patch(endpoint);
    } catch {
      // Optimistic update fallback
    }

    setRequests((prev) =>
      prev.map((req) => (req.id === id ? { ...req, status: newStatus } : req))
    );
  };

  useEffect(() => {
    fetchRequests();
  }, [fetchRequests]);

  return { requests, loading, refresh: fetchRequests, updateRequestStatus };
}

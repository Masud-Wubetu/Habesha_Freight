/**
 * useAvailableLoads – fetches POSTED loads available for the logged-in driver to bid on.
 * Backend endpoint: GET /api/driver/loads/available
 */
import { useEffect, useState, useCallback } from 'react';
import { get } from '../services/api';

export interface AvailableLoad {
  id: string;
  origin_city: string;
  destination_city: string;
  cargo_description: string;
  weight_tons: number;
  offered_price_etb: number;
  status: string;
  shipper_name?: string;
  shipper_phone?: string;
  created_at?: string;
  // mapped UI-friendly aliases
  origin?: string;
  destination?: string;
  cargoType?: string;
  weight?: string;
  bidCount?: number;
}

export function useAvailableLoads() {
  const [loads, setLoads] = useState<AvailableLoad[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchLoads = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await get<any>('/driver/loads/available');
      // Backend may return { success, count, data: [...] } or an array directly
      const raw: any[] = Array.isArray(result)
        ? result
        : result?.data ?? result ?? [];

      const mapped: AvailableLoad[] = raw.map((l) => ({
        ...l,
        origin: l.origin_city,
        destination: l.destination_city,
        cargoType: l.cargo_description,
        weight: l.weight_tons != null ? `${l.weight_tons} t` : '',
        bidCount: l.bid_count ?? 0,
      }));

      setLoads(mapped);
    } catch (e: any) {
      console.error('useAvailableLoads error:', e);
      setError(e?.message ?? 'Unable to load available shipments');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchLoads();
  }, [fetchLoads]);

  return { loads, loading, error, refresh: fetchLoads };
}

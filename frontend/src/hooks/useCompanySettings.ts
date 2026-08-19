import { useEffect, useState, useCallback } from 'react';
import { api } from '../services/api';
import { updateUserProfile, fetchCurrentUser } from '../services/authService';

interface CompanyProfile {
  name: string;
  email: string;
  phone: string;
  tin: string;
  address: string;
}

export function useCompanySettings() {
  const [profile, setProfile] = useState<CompanyProfile>({
    name: '',
    email: '',
    phone: '',
    tin: '',
    address: '',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const fetchProfile = useCallback(async () => {
    setLoading(true);
    try {
      // Attempt to get profile from auth/me
      const user = await api.get<any>('/auth/me');
      setProfile({
        name: user?.fullName || user?.companyName || '',
        email: user?.email || '',
        phone: user?.phone || '',
        tin: user?.tin || user?.businessRegNo || '—',
        address: user?.address || '',
      });
    } catch (e) {
      console.error('Failed to load company profile', e);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchProfile();
  }, [fetchProfile]);

  const saveProfile = useCallback(async (data: Partial<CompanyProfile>) => {
    setSaving(true);
    try {
      // Use auth service patch to update profile
      const updated = await updateUserProfile({
        full_name: data.name,
        email: data.email,
      });
      // Assume phone and address are updated via separate endpoints not shown; we just merge locally
      setProfile((prev) => ({
        ...prev,
        ...data,
        name: updated.fullName || updated.companyName || prev.name,
        email: updated.email || prev.email,
      }));
    } catch (e) {
      console.error('Failed to save company profile', e);
    } finally {
      setSaving(false);
    }
  }, []);

  return { profile, setProfile, loading, saving, saveProfile };
}

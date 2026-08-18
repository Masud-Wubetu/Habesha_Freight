const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

function getAuthHeaders(): Record<string, string> {
  const token =
    localStorage.getItem('authToken') ||
    localStorage.getItem('hf_token') ||
    localStorage.getItem('token');
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}

async function handleResponse<T>(response: Response): Promise<T> {
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const errorMsg = data?.message || `API Request failed with status ${response.status}`;
    throw new Error(errorMsg);
  }
  return data as T;
}

export const api = {
  get: async <T>(endpoint: string, _requireAuth?: boolean): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse<T>(response);
  },

  post: async <T>(endpoint: string, body?: unknown, _requireAuth?: boolean): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: body ? JSON.stringify(body) : undefined,
    });
    return handleResponse<T>(response);
  },

  patch: async <T>(endpoint: string, body?: unknown, _requireAuth?: boolean): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: body ? JSON.stringify(body) : undefined,
    });
    return handleResponse<T>(response);
  },

  delete: async <T>(endpoint: string, _requireAuth?: boolean): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });
    return handleResponse<T>(response);
  },
};

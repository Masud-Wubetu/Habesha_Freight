const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

function authHeaders(includeAuth: boolean): HeadersInit {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (includeAuth) {
    const token = localStorage.getItem('hf_token');
    if (token) headers.Authorization = `Bearer ${token}`;
  }
  return headers;
}

async function handleResponse<T>(response: Response): Promise<T> {
  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message =
      typeof body.message === 'string' ? body.message : `API Error: ${response.status}`;
    throw new Error(message);
  }
  return body as T;
}

export const api = {
  get: async <T>(endpoint: string, auth = false): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      headers: authHeaders(auth),
    });
    return handleResponse<T>(response);
  },

  post: async <T>(endpoint: string, data?: unknown, auth = false): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers: authHeaders(auth),
      body: data ? JSON.stringify(data) : undefined,
    });
    return handleResponse<T>(response);
  },

  patch: async <T>(endpoint: string, data?: unknown, auth = false): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'PATCH',
      headers: authHeaders(auth),
      body: data ? JSON.stringify(data) : undefined,
    });
    return handleResponse<T>(response);
  },

  delete: async <T>(endpoint: string, auth = false): Promise<T> => {
    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'DELETE',
      headers: authHeaders(auth),
    });
    return handleResponse<T>(response);
  },
};

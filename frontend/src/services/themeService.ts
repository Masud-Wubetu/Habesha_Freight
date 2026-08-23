export const getTheme = (): 'light' | 'dark' => {
  const stored = localStorage.getItem('theme');
  if (stored === 'dark' || stored === 'light') return stored;
  return 'light';
};

export const applyTheme = (theme: 'light' | 'dark') => {
  localStorage.setItem('theme', theme);
  if (theme === 'dark') {
    document.body.classList.add('dark-mode');
  } else {
    document.body.classList.remove('dark-mode');
  }
};

export const toggleTheme = (): 'light' | 'dark' => {
  const current = getTheme();
  const next = current === 'dark' ? 'light' : 'dark';
  applyTheme(next);
  return next;
};

// Apply saved theme immediately on module load
applyTheme(getTheme());

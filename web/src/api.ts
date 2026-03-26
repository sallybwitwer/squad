/** In dev, Vite proxies /api → FastAPI (see vite.config.ts). Override with VITE_API_URL. */
export function apiBase(): string {
  const fromEnv = import.meta.env.VITE_API_URL
  if (fromEnv) return fromEnv.replace(/\/$/, '')
  if (import.meta.env.DEV) return '/api'
  return 'http://127.0.0.1:8000'
}

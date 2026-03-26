import { useCallback, useEffect, useState } from 'react'
import './App.css'

/** In dev, Vite proxies /api → FastAPI (see vite.config.ts). Override with VITE_API_URL. */
function apiBase(): string {
  const fromEnv = import.meta.env.VITE_API_URL
  if (fromEnv) return fromEnv.replace(/\/$/, '')
  if (import.meta.env.DEV) return '/api'
  return 'http://127.0.0.1:8000'
}

type Recruiter = {
  id: string
  name: string | null
}

export default function App() {
  const [recruiters, setRecruiters] = useState<Recruiter[]>([])
  const [loadingList, setLoadingList] = useState(true)
  const [listError, setListError] = useState<string | null>(null)

  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [roleMatches, setRoleMatches] = useState<unknown>(null)
  const [loadingMatches, setLoadingMatches] = useState(false)
  const [matchesError, setMatchesError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    setLoadingList(true)
    setListError(null)
    fetch(`${apiBase()}/recruiters`)
      .then((res) => {
        if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
        return res.json() as Promise<Recruiter[]>
      })
      .then((data) => {
        if (!cancelled) setRecruiters(data)
      })
      .catch((e: unknown) => {
        if (cancelled) return
        const msg =
          e instanceof Error ? e.message : 'Request failed'
        setListError(
          msg === 'Failed to fetch'
            ? 'Could not reach the API. Start the server (e.g. uvicorn on port 8000) and reload.'
            : msg,
        )
      })
      .finally(() => {
        if (!cancelled) setLoadingList(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  const selectRecruiter = useCallback((id: string) => {
    setSelectedId(id)
    setRoleMatches(null)
    setMatchesError(null)
    setLoadingMatches(true)
    fetch(`${apiBase()}/role-matches/${encodeURIComponent(id)}`)
      .then((res) => {
        if (res.status === 404) throw new Error('User not found')
        if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
        return res.json()
      })
      .then((data) => setRoleMatches(data))
      .catch((e: unknown) => {
        const msg = e instanceof Error ? e.message : 'Request failed'
        setMatchesError(
          msg === 'Failed to fetch'
            ? 'Could not reach the API. Is uvicorn running on port 8000?'
            : msg,
        )
      })
      .finally(() => setLoadingMatches(false))
  }, [])

  return (
    <div className="layout">
      <header className="header">
        <h1>Squad</h1>
        <p className="subtitle">Recruiters and role matches</p>
      </header>

      <div className="panels">
        <section className="panel recruiters">
          <h2>Recruiters</h2>
          {loadingList && <p className="muted">Loading…</p>}
          {listError && <p className="error">{listError}</p>}
          {!loadingList && !listError && recruiters.length === 0 && (
            <p className="muted">No recruiters found.</p>
          )}
          <ul className="recruiter-list">
            {recruiters.map((r) => (
              <li key={r.id}>
                <button
                  type="button"
                  className={
                    selectedId === r.id ? 'recruiter-btn selected' : 'recruiter-btn'
                  }
                  onClick={() => selectRecruiter(r.id)}
                >
                  <span className="recruiter-name">{r.name ?? '(no name)'}</span>
                  <span className="recruiter-id">{r.id}</span>
                </button>
              </li>
            ))}
          </ul>
        </section>

        <section className="panel detail">
          <h2>Role matches</h2>
          {!selectedId && (
            <p className="muted">Select a recruiter to load role matches.</p>
          )}
          {selectedId && loadingMatches && <p className="muted">Loading…</p>}
          {selectedId && matchesError && (
            <p className="error">{matchesError}</p>
          )}
          {selectedId && !loadingMatches && !matchesError && roleMatches !== null && (
            <pre className="json-out">
              {JSON.stringify(roleMatches, null, 2)}
            </pre>
          )}
        </section>
      </div>
    </div>
  )
}

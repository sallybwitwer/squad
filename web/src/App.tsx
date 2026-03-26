import { useCallback, useEffect, useState } from 'react'
import { Outlet } from 'react-router-dom'
import { apiBase } from './api'
import './App.css'

export type Recruiter = {
  id: string
  name: string | null
  preference_data_count?: number
  location_preference?: string[]
  other_preferences?: string[]
  role_preferences?: string[]
}

/** Row from GET /role-matches/{user_id}; includes scoring breakdown from preference matching. */
export type RoleMatchRow = {
  role: string | null
  required_location: string | null
  company: string | null
  requirements_structured?: string | null
  final_score?: number
  /** LLM batch path */
  location_preference?: number
  /** Empty-user early-return path in role_matching */
  location_preference_score?: number
  location_preference_matched?: string[]
  other_preferences?: number
  other_preferences_matched?: string[]
  role_classification?: string
  role_preferences?: number
  user_location_preference?: string[]
  user_other_preferences?: string[]
  user_role_preferences?: string[]
}

export type SquadOutletContext = {
  selectedId: string | null
  roleMatches: Record<string, RoleMatchRow> | null
  loadingMatches: boolean
  matchesError: string | null
}

export default function AppLayout() {
  const [recruiters, setRecruiters] = useState<Recruiter[]>([])
  const [recruiterQuery, setRecruiterQuery] = useState('')
  const [loadingList, setLoadingList] = useState(true)
  const [listError, setListError] = useState<string | null>(null)

  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [roleMatches, setRoleMatches] = useState<Record<string, RoleMatchRow> | null>(
    null,
  )
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
        return res.json() as Promise<Record<string, RoleMatchRow>>
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

  const outletContext: SquadOutletContext = {
    selectedId,
    roleMatches,
    loadingMatches,
    matchesError,
  }

  const normalizedQuery = recruiterQuery.trim().toLowerCase()
  const filteredRecruiters = recruiters.filter((r) => {
    if (!normalizedQuery) return true
    const name = (r.name ?? '').toLowerCase()
    return name.includes(normalizedQuery) || r.id.toLowerCase().includes(normalizedQuery)
  })

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
          {!loadingList && !listError && recruiters.length > 0 && (
            <>
              <label htmlFor="recruiter-search" className="role-match-label">
                Search recruiter
              </label>
              <input
                id="recruiter-search"
                type="text"
                className="recruiter-search"
                value={recruiterQuery}
                onChange={(e) => setRecruiterQuery(e.target.value)}
                placeholder="Search by name or id"
              />
              <label htmlFor="recruiter-dropdown" className="role-match-label recruiter-dropdown-label">
                Recruiters (highest preference data first)
              </label>
              <select
                id="recruiter-dropdown"
                className="recruiter-dropdown"
                value={selectedId ?? ''}
                onChange={(e) => {
                  const id = e.target.value
                  if (id) selectRecruiter(id)
                }}
              >
                <option value="">Select a recruiter...</option>
                {filteredRecruiters.map((r) => (
                  <option key={r.id} value={r.id}>
                    {r.name ?? '(no name)'}
                  </option>
                ))}
              </select>
              {filteredRecruiters.length === 0 && (
                <p className="muted">No recruiters match your search.</p>
              )}
            </>
          )}
        </section>

        <section className="panel detail">
          <Outlet context={outletContext} />
        </section>
      </div>
    </div>
  )
}

import { useEffect, useState } from 'react'
import { Link, useParams, useOutletContext } from 'react-router-dom'
import type { SquadOutletContext } from './App.tsx'
import FinalScoreBar from './FinalScoreBar.tsx'
import { apiBase } from './api'
import './App.css'

const DETAIL_FIELDS = [
  { key: 'required_location', label: 'Required location' },
  { key: 'company_name', label: 'Company' },
  { key: 'role', label: 'Role' },
  { key: 'requirements_structured', label: 'Requirements (structured)' },
] as const

function formatValue(value: unknown): string {
  if (value === null || value === undefined) return '—'
  if (typeof value === 'object') return JSON.stringify(value, null, 2)
  return String(value)
}

function stringList(value: unknown): string[] {
  if (!Array.isArray(value)) return []
  return value.filter((x): x is string => typeof x === 'string')
}

/** LLM returns `location_preference`; empty-user shortcut uses `location_preference_score`. */
function locationPreferenceValue(row: Record<string, unknown>): number | undefined {
  const a = row.location_preference
  const b = row.location_preference_score
  if (typeof a === 'number' && !Number.isNaN(a)) return a
  if (typeof b === 'number' && !Number.isNaN(b)) return b
  return undefined
}

function formatComponentScore(n: number | undefined): string {
  if (n === undefined || Number.isNaN(n)) return '—'
  return n.toFixed(3)
}

export default function RoleDetailPage() {
  const { roleId } = useParams<{ roleId: string }>()
  const { selectedId, roleMatches, loadingMatches } =
    useOutletContext<SquadOutletContext>()
  const [data, setData] = useState<Record<string, unknown> | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!roleId) {
      setError('Missing role id')
      setLoading(false)
      return
    }
    let cancelled = false
    setLoading(true)
    setError(null)
    fetch(`${apiBase()}/roles/${encodeURIComponent(roleId)}`)
      .then((res) => {
        if (res.status === 404) throw new Error('Role not found')
        if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
        return res.json() as Promise<Record<string, unknown>>
      })
      .then((json) => {
        if (!cancelled) setData(json)
      })
      .catch((e: unknown) => {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Request failed'
        setError(
          msg === 'Failed to fetch'
            ? 'Could not reach the API. Is uvicorn running on port 8000?'
            : msg,
        )
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [roleId])

  const matchRow =
    roleId && roleMatches && roleMatches[roleId]
      ? (roleMatches[roleId] as Record<string, unknown>)
      : null

  return (
    <>
      <Link to="/" className="back-link">
        ← Back to matches
      </Link>
      <h2 className="role-detail-heading">Role details</h2>
      {roleId && <p className="subtitle mono-id role-detail-id">{roleId}</p>}

      <div className="role-detail-body">
        {loading && <p className="muted">Loading…</p>}
        {error && <p className="error">{error}</p>}
        {!loading && !error && data && (
          <>
            {matchRow && (
              <section className="score-breakdown" aria-labelledby="score-breakdown-heading">
                <h3 id="score-breakdown-heading" className="score-breakdown-title">
                  Preference scoring
                </h3>
                <p className="score-breakdown-lead muted">
                  How this role was scored against the selected recruiter’s saved preferences.
                  Final score is the average of the three components below.
                </p>
                <div className="score-breakdown-final">
                  <FinalScoreBar
                    score={
                      typeof matchRow.final_score === 'number'
                        ? matchRow.final_score
                        : undefined
                    }
                  />
                </div>
                <ul className="score-breakdown-list">
                  <li>
                    <div className="score-breakdown-item-head">
                      <strong>Location preference</strong>
                      <span className="score-breakdown-figure mono-id">
                        {formatComponentScore(locationPreferenceValue(matchRow))}{' '}
                        <span className="score-breakdown-weight">(÷3)</span>
                      </span>
                    </div>
                    <p className="score-breakdown-matched-label">User prefs counted as matched</p>
                    {stringList(matchRow.location_preference_matched).length > 0 ? (
                      <ul className="score-breakdown-tags">
                        {stringList(matchRow.location_preference_matched).map((s) => (
                          <li key={s}>{s}</li>
                        ))}
                      </ul>
                    ) : (
                      <p className="muted score-breakdown-none">None</p>
                    )}
                  </li>
                  <li>
                    <div className="score-breakdown-item-head">
                      <strong>Other preferences</strong>
                      <span className="score-breakdown-figure mono-id">
                        {formatComponentScore(
                          typeof matchRow.other_preferences === 'number'
                            ? matchRow.other_preferences
                            : undefined,
                        )}{' '}
                        <span className="score-breakdown-weight">(÷3)</span>
                      </span>
                    </div>
                    <p className="score-breakdown-matched-label">
                      Your “other” prefs matched to this role’s requirements
                    </p>
                    {stringList(matchRow.other_preferences_matched).length > 0 ? (
                      <ul className="score-breakdown-tags">
                        {stringList(matchRow.other_preferences_matched).map((s) => (
                          <li key={s}>{s}</li>
                        ))}
                      </ul>
                    ) : (
                      <p className="muted score-breakdown-none">None</p>
                    )}
                  </li>
                  <li>
                    <div className="score-breakdown-item-head">
                      <strong>Role type preference</strong>
                      <span className="score-breakdown-figure mono-id">
                        {formatComponentScore(
                          typeof matchRow.role_preferences === 'number'
                            ? matchRow.role_preferences
                            : undefined,
                        )}{' '}
                        <span className="score-breakdown-weight">(÷3)</span>
                      </span>
                    </div>
                    <p className="score-breakdown-meta">
                      Classified as{' '}
                      <span className="mono-id">
                        {typeof matchRow.role_classification === 'string'
                          ? matchRow.role_classification
                          : '—'}
                      </span>
                      ; compared to your tech / non-tech preferences.
                    </p>
                  </li>
                </ul>
              </section>
            )}
            {!matchRow && selectedId && loadingMatches && (
              <p className="muted score-breakdown-missing">Loading match scores…</p>
            )}
            {!matchRow && selectedId && !loadingMatches && roleMatches !== null && (
              <p className="muted score-breakdown-missing">
                Preference scoring isn’t available for this role in the current results (it may be
                below the score threshold, or open it from the match list after loading matches).
              </p>
            )}
            {!matchRow && !selectedId && (
              <p className="muted score-breakdown-missing">
                Select a recruiter in the left panel and load matches to see scoring details here.
              </p>
            )}
            <h3 className="role-fields-heading">Role fields</h3>
            <dl className="detail-dl">
              {DETAIL_FIELDS.map(({ key, label }) => {
                const value = data[key]
                return (
                  <div key={key} className="detail-row">
                    <dt>{label}</dt>
                    <dd
                      className={
                        typeof value === 'object' && value !== null
                          ? 'detail-dd-json'
                          : ''
                      }
                    >
                      {formatValue(value)}
                    </dd>
                  </div>
                )
              })}
            </dl>
          </>
        )}
      </div>
    </>
  )
}

import { Link, useOutletContext } from 'react-router-dom'
import type { SquadOutletContext } from './App.tsx'

export default function MatchesPanel() {
  const { selectedId, roleMatches, loadingMatches, matchesError } =
    useOutletContext<SquadOutletContext>()

  return (
    <>
      <h2>Role matches</h2>
      {!selectedId && (
        <p className="muted">Select a recruiter to load role matches.</p>
      )}
      {selectedId && loadingMatches && <p className="muted">Loading…</p>}
      {selectedId && matchesError && (
        <p className="error">{matchesError}</p>
      )}
      {selectedId &&
        !loadingMatches &&
        !matchesError &&
        roleMatches !== null &&
        Object.keys(roleMatches).length === 0 && (
          <p className="muted">No role matches above the score threshold.</p>
        )}
      {selectedId &&
        !loadingMatches &&
        !matchesError &&
        roleMatches !== null &&
        Object.keys(roleMatches).length > 0 && (
          <ul className="role-match-list">
            {Object.entries(roleMatches).map(([roleId, row]) => (
              <li key={roleId}>
                <Link
                  to={`roles/${encodeURIComponent(roleId)}`}
                  className="role-match-link"
                >
                  <span className="role-match-title">{row.role ?? '—'}</span>
                  <span className="role-match-meta">
                    <span className="role-match-label">Location</span>
                    {row.required_location ?? '—'}
                  </span>
                  <span className="role-match-meta">
                    <span className="role-match-label">Company</span>
                    {row.company ?? '—'}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        )}
    </>
  )
}

import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
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

export default function RoleDetailPage() {
  const { roleId } = useParams<{ roleId: string }>()
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
        )}
      </div>
    </>
  )
}

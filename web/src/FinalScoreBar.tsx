type Tier = 'low' | 'mid' | 'high'

const THIRD = 1 / 3
const TWO_THIRDS = 2 / 3

function tierForScore(score: number): { tier: Tier; fillFraction: number } {
  if (score <= THIRD) return { tier: 'low', fillFraction: THIRD }
  if (score <= TWO_THIRDS) return { tier: 'mid', fillFraction: TWO_THIRDS }
  return { tier: 'high', fillFraction: 1 }
}

type Props = {
  score: number | undefined | null
}

export default function FinalScoreBar({ score }: Props) {
  if (score == null || Number.isNaN(score)) {
    return (
      <span className="role-match-meta">
        <span className="role-match-label">Final score</span>
        —
      </span>
    )
  }

  const { tier, fillFraction } = tierForScore(score)
  const pct = `${(fillFraction * 100).toFixed(2)}%`

  return (
    <div className="role-match-meta score-bar-wrap">
      <span className="role-match-label">Final score</span>
      <div
        className="score-bar-track"
        role="img"
        aria-label={`Final score ${score.toFixed(3)}`}
      >
        <div
          className={`score-bar-fill score-bar-fill--${tier}`}
          style={{ width: pct }}
        />
      </div>
      <span className="score-bar-numeric">{score.toFixed(3)}</span>
    </div>
  )
}

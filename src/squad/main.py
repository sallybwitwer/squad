from fastapi import FastAPI

from src.models.sqlmodel_tables import Role, User
from sqlmodel import create_engine, Session, select
from src.squad.role_matching import get_user_preference_match_score, get_role_similarity_score
from fastapi import HTTPException
import os

DATABASE_URL = os.getenv("DATABASE_URL")

app = FastAPI(title="Squad API")
engine = create_engine(DATABASE_URL)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}




@app.get("/role-matches/{user_id}")
def get_role_matches(user_id: str) -> list[dict[str, str | float]]:
    print(f"Getting role matches for user: {user_id}")
    with Session(engine) as session:
        # get all users
        user = session.exec(select(User).where(User.id == user_id)).first()
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")

        roles = session.exec(select(Role)).all() 
        

        # TODO: compare against all preferences, not just location
        user_preference_scores = get_user_preference_match_score(user, roles)

        # TODO: get role similarity score
        # role_similarity_scores = get_role_similarity_score(user, roles, saved_roles, previously_submitted_roles)

        # return all roles with user preference score greater than 0.5
        response = [{"role_id": role.id, "score": user_preference_scores.get(role.id, 0)} for role in roles if user_preference_scores.get(role.id, 0) > 0.5] 
        return response

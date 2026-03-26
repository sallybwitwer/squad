from typing import Any, List

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.models.sqlmodel_tables import Role, User, Company
from src.models.enums import UserType
from sqlmodel import create_engine, Session, select
from src.squad.role_matching import get_user_preference_match_score, get_role_similarity_score
from fastapi import HTTPException
import os

DATABASE_URL = os.getenv("DATABASE_URL")

app = FastAPI(title="Squad API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:5173",
        "http://localhost:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
engine = create_engine(DATABASE_URL)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/recruiters")
def get_recruiters() -> List[dict[str, Any]]:
    with Session(engine) as session:
        recruiters = session.exec(select(User).where(User.user_type == UserType.RECRUITER)).all()
        return [
            {
                "id": recruiter.id,
                "name": recruiter.name,
            }
            for recruiter in recruiters
        ]

@app.get("/roles/{role_id}")
def get_role(role_id: str) -> dict[str, Any]:
    with Session(engine) as session:
        role = session.exec(select(Role).where(Role.id == role_id)).first()
        if role is None:
            raise HTTPException(status_code=404, detail="Role not found")
        payload = role.model_dump(
            mode="json",
            exclude={"company", "saved_roles", "applications"},
        )
        if role.company_id:
            co = session.get(Company, role.company_id)
            payload["company_name"] = co.name if co else None
        else:
            payload["company_name"] = None
        return payload


@app.get("/role-matches/{user_id}")
def get_role_matches(user_id: str) -> dict[str, dict[str, Any]]:
    print(f"Getting role matches for user: {user_id}")
    with Session(engine) as session:
        # get all users
        user = session.exec(select(User).where(User.id == user_id)).first()
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")

        # get top ten roles
        roles = session.exec(select(Role).where(Role.is_accepting_new_submissions == True).order_by(Role.created_at.desc()).limit(10)).all()
        
        user_preference_scores = get_user_preference_match_score(user, roles) 
        # get all roles with final_score greater than 0.5
        matching_user_preferences = { # role id to user preference score
            role.id: user_preference_scores.get(role.id, {}).get("final_score", 0)
            for role in roles
            if user_preference_scores.get(role.id, {}).get("final_score", 0) > 0.5
        }

        # TODO: get role similarity score
        # role_similarity_scores = get_role_similarity_score(user, roles, saved_roles, previously_submitted_roles)

        def company_name(r: Role) -> str | None:
            if not r.company_id:
                return None
            co = session.exec(select(Company).where(Company.id == r.company_id)).first()
            return co.name if co else None

        return {
            role.id: {
                "required_location": role.required_location,
                "role": role.role,
                "company": company_name(role),
                "requirements_structured": role.requirements_structured,
                "user_location_preference": user.location_preference,
                "user_other_preferences": user.other_preferences,
                "user_role_preferences": user.role_preferences,
                **user_preference_scores.get(role.id, {}),
            }
            for role in roles
            if user_preference_scores.get(role.id, {}).get("final_score", 0) > 0.5
        }

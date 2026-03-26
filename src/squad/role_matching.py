from src.models.sqlmodel_tables import Role, User
from sqlmodel import create_engine, Session, select
from typing import List
import os
from src.api.openai_api import get_client
import json

client = get_client()

engine = create_engine(os.getenv("DATABASE_URL"))



def get_user_preference_match_score(user: User, roles: list[Role]):
    # get all roles where location requirements match the user's location preference


    user_preferences = {
        "location_preference": user.location_preference,
        "other_preferences": user.other_preferences,
        "role_preferences": user.role_preferences
    }

    if all(value is None for value in user_preferences.values()):
        return {
            role.id: 1.0
            for role in roles
        }

    role_data = {
        role.id: {
            "required_location": role.required_location if (user.location_preference or user.role_type) else None,
            "role_type": role.role_type,
            "requirements_structured": role.requirements_structured
        }
        for role in roles
    }

    # if they are all none, return all roles
   

    prompt = (f"Return a mapping of all role ids to their final scores." +
    f"For each role, compute three scores: location_preference, other_preferences, and role_preferences. All scores should be between 0 and 1. If no data exists for the user's side of the comparison, then the score should be 1.0. " +
    f"1. user location_preference: Compare the user's location preference against the role's required location and the role's role_type and give a score between 0 and 1 based on how well they match. If required location is none, the score should be 1.0." +
    f"2. user other_preferences: Compare the user's other preferences against the role's requirements_structured and give a score between 0 and 1 based on how well they match."
    f"3. user role_preferences: If user role_preferences are None, the score should be 1.0. Classify whether the role is a tech role or a non tech role. If the result of the classification is in the user's role_preferences, the score should be 1.0. Otherwise, the score should be -1.0." +
    f"The final score should be the sum of the three parts divided by 3." +
        f"The user's preferences are: {user_preferences}"+
        f"And the roles are: {role_data}" +
        f"The output should be a dictionary. The dictionary keys should be the role ids and the values should be the final scores."
    )
    

    response = client.chat.completions.create(model="gpt-5.4-mini-2026-03-17", messages=[{"role": "user", "content": prompt}])
    # get reasoning
    role_scores = response.choices[0].message.content
    print(role_scores)
    return json.loads(role_scores) if role_scores else {}

def get_role_similarity_score(user: User, role: Role, previously_submitted_roles: list[Role], saved_roles: list[Role]) -> float:
    pass


def get_roles() -> list[Role]:
    with Session(engine) as session:
        roles = session.exec(select(Role).where(Role.is_accepting_new_submissions == True)).all()
        return roles


def get_role_matches(user_id: str) -> list[Role]:

    pass
from typing import Any

from src.models.sqlmodel_tables import Role, User
from sqlmodel import create_engine, Session, select
import os
from src.api.openai_api import get_client
import json

client = get_client()

engine = create_engine(os.getenv("DATABASE_URL"))

def _loads_json_object(text: str) -> dict:
    text = (text or "").strip()
    if not text:
        return {}

    try:
        value = json.loads(text)
        return value if isinstance(value, dict) else {}
    except json.JSONDecodeError:
        pass

    start = text.find("{")
    end = text.rfind("}")
    if start == -1 or end == -1 or end <= start:
        return {}

    try:
        value = json.loads(text[start : end + 1])
        return value if isinstance(value, dict) else {}
    except json.JSONDecodeError:
        return {}


RoleScoreBreakdown = dict[str, Any]


def get_user_preference_match_score(user: User, roles: list[Role]) -> dict[str, RoleScoreBreakdown]:
    # get all roles where location requirements match the user's location preference


    user_preferences = {
        "user_location_preference": user.location_preference,
        "user_other_preferences": user.other_preferences,
        "user_role_preferences": user.role_preferences
    }

    if all(value is None for value in user_preferences.values()):
        return {
            role.id: {
                "location_preference_score": 1.0,
                "location_preference_matched": [],
                "other_preferences": 1.0,
                "other_preferences_matched": [],
                "role_preferences": 1.0,
                "final_score": 1.0,
            }
            for role in roles
        }

    role_data = {
        role.id: {
            "required_location": (
                (str(role.role_type) if role.role_type else "") +
                (str(role.required_location) if role.required_location else "")
            ),
            "role_type": role.role_type,
            "requirements_structured": (
                role.requirements_structured + 
                (str(role.role_type) if role.role_type else "") + 
                (str(role.required_location) if role.required_location else "") +
                (str(role.role) if role.role else "")
            )
        }
        for role in roles
    } 

    prompt = (
        "Return JSON only.\n"
        "Return a dictionary mapping each role_id to an object with:\n"
        '- "location_preference": number between 0 and 1\n'
        '- "location_preference_matched": array of strings; each entry must be exactly one '
        "of the user's user_location_preference items you counted as matched for this role "
        "(verbatim; use [] if none)\n"
        '- "other_preferences": number between 0 and 1\n'
        '- "other_preferences_matched": array of strings; each entry must be exactly one of the user\'s other_preferences items that you judged as inferable from requirements_structured for this role (use [] if none match or user has no other preferences)\n'
        '- "role_classification": "tech" or "non_tech"\n'
        '- "role_preferences": number between 0 and 1\n'
        '- "final_score": number between 0 and 1\n'
        "\n"
        "Rules:\n"
        "- If a user preference has no data, that preference score must be 1.0.\n"
        "- If role has no relevant data, treat it as a perfect match (1.0).\n"
        "- final_score must be (location_preference + other_preferences + role_preferences) / 3.\n"
        "\n"
        "How to score:\n"
        "- location_preference: compare user_location_preference vs the role's "
        "required_location and role_type fields in the Roles payload. If data is missing, "
        "then 1.0. Use normal geography: city within state/province within country within "
        "continent; treat common aliases as the same place (e.g. NYC and New York City). "
        "Containment counts both ways: if the user names a broader place (e.g. country or "
        "region) and the role names a narrower place inside it (e.g. a city in that "
        "country), that is a match — e.g. user_location_preference includes \"USA\" and "
        "the role location includes \"NYC\" → location_preference 1.0 and "
        "location_preference_matched includes \"USA\". If a match is found, location_preference is 1.0; "
        "otherwise -1.0. Set location_preference_matched to the list of "
        "user_location_preference strings (verbatim) you counted as matched.\n"
        "- other_preferences: compare user_other_preferences vs role.requirements_structured. "
        "Infer which of the user_other_preferences are matched to the "
        "requirements_structured. If there is a match, then 1.0, otherwise 0.0. Also set "
        "other_preferences_matched to the list of those user_other_preferences strings "
        "(verbatim) that you counted as matched for this role.\n"
        '- role_classification: classify role as "tech" or "non_tech".\n'
        '- role_preferences: if role_classification is in user_role_preferences, '
        "then 1.0, else -1.0.\n"
        "\n"
        f"User preferences:\n{user_preferences}\n"
        f"Roles:\n{role_data}\n"
    )

    
    

    response = client.chat.completions.create(model="gpt-5.4", messages=[{"role": "user", "content": prompt}])
    # get reasoning
    role_scores = response.choices[0].message.content
    print(role_scores)
    return _loads_json_object(role_scores)

def get_role_similarity_score(user: User, role: Role, previously_submitted_roles: list[Role], saved_roles: list[Role]) -> float:
    pass


def get_roles() -> list[Role]:
    with Session(engine) as session:
        roles = session.exec(select(Role).where(Role.is_accepting_new_submissions == True)).all()
        return roles


def get_role_matches(user_id: str) -> list[Role]:

    pass
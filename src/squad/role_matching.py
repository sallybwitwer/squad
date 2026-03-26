from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Any

from src.models.sqlmodel_tables import Role, User
from sqlmodel import create_engine, Session, select
import os
from src.api.openai_api import get_client
import json

client = get_client()

engine = create_engine(os.getenv("DATABASE_URL"))

def _user_preference_fields_empty(user_preferences: dict[str, Any]) -> bool:
    for key in ("user_location_preference", "user_other_preferences", "user_role_preferences"):
        v = user_preferences.get(key)
        if v is None:
            continue
        if isinstance(v, (list, tuple)) and len(v) == 0:
            continue
        if isinstance(v, str) and not v.strip():
            continue
        return False
    return True


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

_DEFAULT_BATCH_SIZE = 8
_DEFAULT_MAX_PARALLEL_BATCHES = 4


def _role_payload_for_matching(roles: list[Role]) -> dict[str, dict[str, Any]]:
    return {
        role.id: {
            "required_location": (
                (str(role.role_type) if role.role_type else "")
                + (str(role.required_location) if role.required_location else "")
            ),
            "role_type": role.role_type,
            "requirements_structured": (
                (role.requirements_structured if role.requirements_structured else "")
                + (role.role if role.role else "")
            ),
        }
        for role in roles
    }


def _preference_match_prompt(user_preferences: dict[str, Any], role_data: dict[str, dict[str, Any]]) -> str:
    return (
        "Return JSON only: one object keyed by role_id. Each value has:\n"
        '- location_preference: -1.0 | 0.5 | 1.0; location_preference_matched: verbatim '
        "user_location_preference strings you counted as matched, else []\n"
        '- other_preferences: 0.0 | 0.5 | 1.0; other_preferences_matched: verbatim '
        "user_other_preferences inferable from requirements_structured, else []\n"
        '- role_classification: "tech" | "non_tech"\n'
        "- role_preferences: -1.0 | 0.5 | 1.0\n"
        "- final_score: (location_preference + other_preferences + role_preferences) / 3 (exact)\n"
        "\n"
        "Defaults: if the user or role lacks data for a dimension, that preference score is 0.5. "
        "If the role has no usable location/requirements text, treat as partial (0.5) for that part.\n"
        "\n"
        "Location: compare user_location_preference to required_location + role_type in Roles. "
        "Use normal geography: city within state/province within country within "
        "continent; treat common aliases as the same place (e.g. NYC and New York City). "
        "Containment counts both ways: if the user names a broader place (e.g. country or "
        "region) and the role names a narrower place inside it (e.g. a city in that "
        "country), that is a match — e.g. user_location_preference includes \"USA\" and "
        "the role location includes \"NYC\" → location_preference 1.0 and "
        "location_preference_matched includes \"USA\".\n"
        "1.0 if any match; -1.0 if mismatch.\n"
        "Set location_preference_matched to the list of "
        "user_location_preference strings (verbatim) you counted as matched.\n"
        "\n"
        "Other: match user_other_preferences to requirements_structured by inference. "
        "1.0 if ≥1 match, 0.0 if none, and 0.5 if user or role data is missing; "
        "list matched strings in other_preferences_matched.\n"
        "\n"
        "Role type: set role_classification. role_preferences is 1.0 if that classification "
        "is in user_role_preferences, -1.0 if not, and 0.5 if user or role data is missing.\n"
        "\n"
        f"User preferences:\n{user_preferences}\n"
        f"Roles:\n{role_data}\n"
    )


def _preference_match_one_batch(user_preferences: dict[str, Any], role_data: dict[str, dict[str, Any]]) -> dict[str, Any]:
    prompt = _preference_match_prompt(user_preferences, role_data)
    response = client.chat.completions.create(
        model="gpt-5.4-mini",
        messages=[{"role": "user", "content": prompt}],
    )
    content = response.choices[0].message.content
    return _loads_json_object(content or "")


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
                "location_preference_score": 0.5,
                "location_preference_matched": [],
                "other_preferences": 0.5,
                "other_preferences_matched": [],
                "role_preferences": 0.5,
                "final_score": 0.5,
            }
            for role in roles
        }

    if not roles:
        return {}

    try:
        batch_size = max(1, int(os.getenv("ROLE_MATCH_BATCH_SIZE", str(_DEFAULT_BATCH_SIZE))))
    except ValueError:
        batch_size = _DEFAULT_BATCH_SIZE
    try:
        max_workers = max(1, int(os.getenv("ROLE_MATCH_MAX_PARALLEL", str(_DEFAULT_MAX_PARALLEL_BATCHES))))
    except ValueError:
        max_workers = _DEFAULT_MAX_PARALLEL_BATCHES

    role_payload = _role_payload_for_matching(roles)
    batches: list[list[Role]] = [roles[i : i + batch_size] for i in range(0, len(roles), batch_size)]
    merged: dict[str, RoleScoreBreakdown] = {}

    def run_batch(batch: list[Role]) -> dict[str, Any]:
        data = {r.id: role_payload[r.id] for r in batch}
        return _preference_match_one_batch(user_preferences, data)

    if len(batches) == 1:
        merged.update(run_batch(batches[0]))
    else:
        workers = min(max_workers, len(batches))
        with ThreadPoolExecutor(max_workers=workers) as pool:
            futures = [pool.submit(run_batch, b) for b in batches]
            for fut in as_completed(futures):
                merged.update(fut.result())

    return merged

def get_role_similarity_score(user: User, role: Role, previously_submitted_roles: list[Role], saved_roles: list[Role]) -> float:
    pass


def get_roles() -> list[Role]:
    with Session(engine) as session:
        roles = session.exec(select(Role).where(Role.is_accepting_new_submissions == True)).all()
        return roles


def get_role_matches(user_id: str) -> list[Role]:

    pass
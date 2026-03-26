"""SQLModel ORM definitions for selected tables (mirrors db_schema.sql and tables.py)."""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import ARRAY, Boolean, Column, Float, ForeignKey, Integer, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import TIMESTAMP, UUID
from sqlalchemy.dialects.postgresql import ENUM as PG_ENUM
from sqlalchemy.sql import text as sa_text
from sqlmodel import Field, Relationship, SQLModel

from src.models.enums import ApplicationOrigin, UserType

_TS3 = TIMESTAMP(precision=3, timezone=False)


def _pg_enum(enum_cls: type, name: str) -> PG_ENUM:
    return PG_ENUM(
        enum_cls,
        name=name,
        schema="public",
        create_type=False,
        values_callable=lambda x: [e.value for e in x],
    )


_application_origin = _pg_enum(ApplicationOrigin, "ApplicationOrigin")
_user_type = _pg_enum(UserType, "UserType")


class User(SQLModel, table=True):
    __tablename__ = "User"

    id: str = Field(
        sa_column=Column(
            Text,
            primary_key=True,
            server_default=sa_text("gen_random_uuid()::text"),
        )
    )
    whalesync_postgres_id: Optional[uuid.UUID] = Field(
        default=None,
        sa_column=Column(UUID(as_uuid=True), unique=True, nullable=True),
    )
    email: Optional[str] = Field(default=None, sa_column=Column(Text, unique=True))
    name: Optional[str] = Field(default=None, sa_column=Column("name", Text))
    slack_user_id: Optional[str] = Field(
        default=None, sa_column=Column("slackUserId", Text, unique=True)
    )
    user_type: Optional[UserType] = Field(
        default=None,
        sa_column=Column(
            "userType",
            _user_type,
            server_default=sa_text("'RECRUITER'::\"UserType\""),
        ),
    )
    last_login: Optional[datetime] = Field(
        default=None, sa_column=Column("lastLogin", _TS3)
    )
    active: Optional[bool] = Field(
        default=None, sa_column=Column(Boolean, server_default=sa_text("true"))
    )
    created_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("createdAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("updatedAt", _TS3)
    )
    priority_opportunities_fk_role: list[str] = Field(
        sa_column=Column(
            "priorityOpportunities_fk_Role",
            ARRAY(Text),
            server_default=sa_text("ARRAY[]::text[]"),
        )
    )
    airtable_id: Optional[str] = Field(
        default=None, sa_column=Column(Text, unique=True)
    )
    priority_opportunities_fk_role_airtable: list[str] = Field(
        sa_column=Column(
            "priorityOpportunities_fk_Role_airtable",
            ARRAY(Text),
            server_default=sa_text("ARRAY[]::text[]"),
        )
    )
    deleted_at: Optional[datetime] = Field(
        default=None, sa_column=Column("deletedAt", _TS3)
    )
    asked_preferences: Optional[bool] = Field(
        default=None,
        sa_column=Column("askedPreferences", Boolean, server_default=sa_text("false")),
    )
    location_preference: list[str] = Field(
        sa_column=Column(
            "locationPreference", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )
    other_preferences: list[str] = Field(
        sa_column=Column(
            "otherPreferences", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )
    recruiter_preference: Optional[str] = Field(
        default=None, sa_column=Column("recruiterPreference", Text)
    )
    role_preferences: list[str] = Field(
        sa_column=Column(
            "rolePreferences", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )

    candidates: list["Candidate"] = Relationship(
        sa_relationship=relationship("Candidate", back_populates="user")
    )
    saved_roles: list["SavedRole"] = Relationship(
        sa_relationship=relationship("SavedRole", back_populates="user")
    )


class Role(SQLModel, table=True):
    __tablename__ = "Role"

    id: str = Field(
        sa_column=Column(
            Text,
            primary_key=True,
            server_default=sa_text("gen_random_uuid()::text"),
        )
    )
    whalesync_postgres_id: Optional[uuid.UUID] = Field(
        default=None,
        sa_column=Column(UUID(as_uuid=True), unique=True, nullable=True),
    )
    ref: Optional[str] = Field(default=None, sa_column=Column("ref", Text))
    role: Optional[str] = Field(default=None, sa_column=Column("role", Text))
    enhanced_jd: Optional[str] = Field(default=None, sa_column=Column("enhancedJd", Text))
    rejections_log: Optional[str] = Field(
        default=None, sa_column=Column("rejectionsLog", Text)
    )
    required_location: Optional[str] = Field(
        default=None, sa_column=Column("requiredLocation", Text)
    )
    comp: Optional[str] = Field(default=None, sa_column=Column(Text))
    total_shared_with_client: Optional[int] = Field(
        default=None, sa_column=Column("totalSharedWithClient", Integer)
    )
    internal_id: Optional[int] = Field(default=None, sa_column=Column("internalId", Integer))
    company_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            "companyId",
            Text,
            ForeignKey("Company.id", ondelete="SET NULL", onupdate="CASCADE"),
        ),
    )
    last_synced_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("lastSyncedAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    created_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("createdAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("updatedAt", _TS3)
    )
    status_internal: Optional[str] = Field(
        default=None, sa_column=Column("statusInternal", Text)
    )
    skills_fk_skill: list[str] = Field(
        sa_column=Column(
            "skills_fk_Skill", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )
    max_compensation: Optional[str] = Field(
        default=None, sa_column=Column("maxCompensation", Text)
    )
    required_overlap: Optional[str] = Field(
        default=None, sa_column=Column("requiredOverlap", Text)
    )
    role_priority: Optional[str] = Field(
        default=None, sa_column=Column("rolePriority", Text)
    )
    airtable_id: Optional[str] = Field(
        default=None, sa_column=Column(Text, unique=True)
    )
    company_id_airtable: Optional[str] = Field(
        default=None, sa_column=Column("companyId_airtable", Text)
    )
    skills_fk_skill_airtable: list[str] = Field(
        sa_column=Column(
            "skills_fk_Skill_airtable",
            ARRAY(Text),
            server_default=sa_text("ARRAY[]::text[]"),
        )
    )
    key_indicators: list[str] = Field(
        sa_column=Column(
            "keyIndicators", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )
    indep_recruiters: Optional[str] = Field(
        default=None, sa_column=Column("indepRecruiters", Text)
    )
    is_accepting_new_submissions: Optional[bool] = Field(
        default=None,
        sa_column=Column("isAcceptingNewSubmissions", Boolean, server_default=sa_text("true")),
    )
    deleted_at: Optional[datetime] = Field(
        default=None, sa_column=Column("deletedAt", _TS3)
    )
    continents: Optional[str] = Field(default=None, sa_column=Column(Text))
    requirements_structured: Optional[str] = Field(
        default=None, sa_column=Column("requirementsStructured", Text)
    )
    find_candidates_run_id: Optional[str] = Field(
        default=None, sa_column=Column("findCandidatesRunId", Text)
    )
    internal_evaluation: Optional[str] = Field(
        default=None, sa_column=Column("internalEvaluation", Text)
    )
    countries: Optional[str] = Field(default=None, sa_column=Column(Text))
    role_type: Optional[str] = Field(default=None, sa_column=Column("roleType", Text))

    saved_roles: list["SavedRole"] = Relationship(
        sa_relationship=relationship("SavedRole", back_populates="role")
    )
    applications: list["CandidateApplication"] = Relationship(
        sa_relationship=relationship("CandidateApplication", back_populates="role")
    )


class Candidate(SQLModel, table=True):
    __tablename__ = "Candidate"

    id: str = Field(
        sa_column=Column(
            Text,
            primary_key=True,
            server_default=sa_text("gen_random_uuid()::text"),
        )
    )
    whalesync_postgres_id: Optional[uuid.UUID] = Field(
        default=None,
        sa_column=Column(UUID(as_uuid=True), unique=True, nullable=True),
    )
    name: Optional[str] = Field(default=None, sa_column=Column("name", Text))
    email: Optional[str] = Field(default=None, sa_column=Column(Text))
    location: Optional[str] = Field(default=None, sa_column=Column("location", Text))
    linked_in: Optional[str] = Field(default=None, sa_column=Column("linkedIn", Text))
    git_hub: Optional[str] = Field(default=None, sa_column=Column("gitHub", Text))
    cv: Optional[str] = Field(default=None, sa_column=Column(Text))
    resume_attachment: Optional[str] = Field(
        default=None, sa_column=Column("resumeAttachment", Text)
    )
    salary_expectations: Optional[str] = Field(
        default=None, sa_column=Column("salaryExpectations", Text)
    )
    comp_min: Optional[str] = Field(default=None, sa_column=Column("compMin", Text))
    description: Optional[str] = Field(default=None, sa_column=Column(Text))
    previous_roles: Optional[str] = Field(
        default=None, sa_column=Column("previousRoles", Text)
    )
    notice_period: Optional[str] = Field(
        default=None, sa_column=Column("noticePeriod", Text)
    )
    all_skills: list[str] = Field(
        sa_column=Column(
            "allSkills", ARRAY(Text), server_default=sa_text("ARRAY[]::text[]")
        )
    )
    all_skills_structured: Optional[str] = Field(
        default=None, sa_column=Column("allSkillsStructured", Text)
    )
    tech_stack1: Optional[str] = Field(default=None, sa_column=Column("techStack1", Text))
    tech_stack1_xp: Optional[int] = Field(
        default=None, sa_column=Column("techStack1Xp", Integer)
    )
    tech_stack2: Optional[str] = Field(default=None, sa_column=Column("techStack2", Text))
    tech_stack2_xp: Optional[int] = Field(
        default=None, sa_column=Column("techStack2Xp", Integer)
    )
    tech_stack3: Optional[str] = Field(default=None, sa_column=Column("techStack3", Text))
    tech_stack3_xp: Optional[int] = Field(
        default=None, sa_column=Column("techStack3Xp", Integer)
    )
    selling_points: Optional[str] = Field(
        default=None, sa_column=Column("sellingPoints", Text)
    )
    other_notes: Optional[str] = Field(default=None, sa_column=Column("otherNotes", Text))
    addtl_comments: Optional[str] = Field(
        default=None, sa_column=Column("addtlComments", Text)
    )
    telegram_for_comms: Optional[str] = Field(
        default=None, sa_column=Column("telegramForComms", Text)
    )
    timezone: Optional[str] = Field(default=None, sa_column=Column(Text))
    xp_years: Optional[int] = Field(default=None, sa_column=Column("xpYears", Integer))
    technical_rating: Optional[str] = Field(
        default=None, sa_column=Column("technicalRating", Text)
    )
    sponsorship: Optional[str] = Field(default=None, sa_column=Column(Text))
    fit_confidence: Optional[str] = Field(
        default=None, sa_column=Column("fitConfidence", Text)
    )
    user_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            "userId",
            Text,
            ForeignKey("User.id", ondelete="SET NULL", onupdate="CASCADE"),
        ),
    )
    last_synced_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("lastSyncedAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    submitted_at: Optional[datetime] = Field(
        default=None, sa_column=Column("submittedAt", _TS3)
    )
    updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("updatedAt", _TS3)
    )
    stage_with_squad: Optional[str] = Field(
        default=None, sa_column=Column("stageWithSquad", Text)
    )
    seniority: Optional[str] = Field(default=None, sa_column=Column(Text))
    dev_type: Optional[str] = Field(default=None, sa_column=Column("devType", Text))
    availability_status: Optional[str] = Field(
        default=None, sa_column=Column("availabilityStatus", Text)
    )
    quality: Optional[str] = Field(default=None, sa_column=Column(Text))
    other_docs: Optional[str] = Field(default=None, sa_column=Column("otherDocs", Text))
    technical_completed: Optional[int] = Field(
        default=None, sa_column=Column("technicalCompleted", Integer)
    )
    airtable_id: Optional[str] = Field(
        default=None, sa_column=Column(Text, unique=True)
    )
    created_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("createdAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    user_id_airtable: Optional[str] = Field(
        default=None, sa_column=Column("userId_airtable", Text)
    )
    stage_with_squad_updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("stageWithSquadUpdatedAt", _TS3)
    )
    tech_stack_to_be_tested: Optional[str] = Field(
        default=None, sa_column=Column("techStackToBeTested", Text)
    )
    opportunity_id: Optional[str] = Field(
        default=None, sa_column=Column("opportunityId", Text)
    )
    role_opportunity: Optional[str] = Field(
        default=None, sa_column=Column("roleOpportunity", Text)
    )
    deleted_at: Optional[datetime] = Field(
        default=None, sa_column=Column("deletedAt", _TS3)
    )
    continent: Optional[str] = Field(default=None, sa_column=Column(Text))
    available: Optional[str] = Field(default=None, sa_column=Column(Text))
    stage: Optional[str] = Field(default=None, sa_column=Column(Text))
    country: Optional[str] = Field(default=None, sa_column=Column(Text))
    cv_raw_content: Optional[str] = Field(
        default=None, sa_column=Column("cvRawContent", Text)
    )

    user: Optional[User] = Relationship(
        sa_relationship=relationship("User", back_populates="candidates")
    )
    applications: list["CandidateApplication"] = Relationship(
        sa_relationship=relationship(
            "CandidateApplication", back_populates="candidate"
        )
    )


class SavedRole(SQLModel, table=True):
    __tablename__ = "SavedRole"

    user_id: str = Field(
        sa_column=Column(
            "userId",
            Text,
            ForeignKey("User.id", ondelete="RESTRICT", onupdate="CASCADE"),
            primary_key=True,
        )
    )
    role_id: str = Field(
        sa_column=Column(
            "roleId",
            Text,
            ForeignKey("Role.id", ondelete="RESTRICT", onupdate="CASCADE"),
            primary_key=True,
        )
    )
    saved_at: datetime = Field(
        sa_column=Column("savedAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP"))
    )
    notes: Optional[str] = Field(default=None, sa_column=Column(Text))

    user: User = Relationship(
        sa_relationship=relationship("User", back_populates="saved_roles")
    )
    role: Role = Relationship(
        sa_relationship=relationship("Role", back_populates="saved_roles")
    )


class CandidateApplication(SQLModel, table=True):
    __tablename__ = "CandidateApplication"

    id: str = Field(
        sa_column=Column(
            Text,
            primary_key=True,
            server_default=sa_text("gen_random_uuid()::text"),
        )
    )
    whalesync_postgres_id: Optional[uuid.UUID] = Field(
        default=None,
        sa_column=Column(UUID(as_uuid=True), unique=True, nullable=True),
    )
    candidate_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            "candidateId",
            Text,
            ForeignKey("Candidate.id", ondelete="SET NULL", onupdate="CASCADE"),
        ),
    )
    status_updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("statusUpdatedAt", _TS3)
    )
    additional_details: Optional[str] = Field(
        default=None, sa_column=Column("additionalDetails", Text)
    )
    role_id: Optional[str] = Field(
        default=None,
        sa_column=Column(
            "roleId",
            Text,
            ForeignKey("Role.id", ondelete="SET NULL", onupdate="CASCADE"),
        ),
    )
    last_synced_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("lastSyncedAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    created_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("createdAt", _TS3, server_default=sa_text("CURRENT_TIMESTAMP")),
    )
    updated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("updatedAt", _TS3)
    )
    internal_status: Optional[str] = Field(
        default=None, sa_column=Column("internalStatus", Text)
    )
    stage_with_client: Optional[str] = Field(
        default=None, sa_column=Column("stageWithClient", Text)
    )
    follow_up_status: Optional[str] = Field(
        default=None, sa_column=Column("followUpStatus", Text)
    )
    tier: Optional[str] = Field(default=None, sa_column=Column(Text))
    airtable_id_int: Optional[int] = Field(
        default=None, sa_column=Column("airtableId", Integer)
    )
    last_action_taken_at: Optional[datetime] = Field(
        default=None, sa_column=Column("lastActionTakenAt", _TS3)
    )
    rate_override: Optional[str] = Field(
        default=None, sa_column=Column("rateOverride", Text)
    )
    airtable_id: Optional[str] = Field(
        default=None, sa_column=Column(Text, unique=True)
    )
    candidate_id_airtable: Optional[str] = Field(
        default=None, sa_column=Column("candidateId_airtable", Text)
    )
    role_id_airtable: Optional[str] = Field(
        default=None, sa_column=Column("roleId_airtable", Text)
    )
    next_step: Optional[str] = Field(default=None, sa_column=Column("nextStep", Text))
    notes: Optional[str] = Field(default=None, sa_column=Column(Text))
    deleted_at: Optional[datetime] = Field(
        default=None, sa_column=Column("deletedAt", _TS3)
    )
    ai_init_tier: Optional[str] = Field(default=None, sa_column=Column("aiInitTier", Text))
    ai_init_tier_summary: Optional[str] = Field(
        default=None, sa_column=Column("aiInitTierSummary", Text)
    )
    cons_summary: Optional[str] = Field(
        default=None, sa_column=Column("consSummary", Text)
    )
    detailed_evaluation_doc: Optional[str] = Field(
        default=None, sa_column=Column("detailedEvaluationDoc", Text)
    )
    evaluation_timestamp: Optional[datetime] = Field(
        default=None, sa_column=Column("evaluationTimestamp", _TS3)
    )
    overall_summary: Optional[str] = Field(
        default=None, sa_column=Column("overallSummary", Text)
    )
    pros_summary: Optional[str] = Field(
        default=None, sa_column=Column("prosSummary", Text)
    )
    reason_for_init_tier_summary: Optional[str] = Field(
        default=None, sa_column=Column("reasonForInitTierSummary", Text)
    )
    reason_for_post_tier_summary: Optional[str] = Field(
        default=None, sa_column=Column("reasonForPostTierSummary", Text)
    )
    summary_score: Optional[str] = Field(
        default=None, sa_column=Column("summaryScore", Text)
    )
    summary_score_numeric: Optional[float] = Field(
        default=None, sa_column=Column("summaryScoreNumeric", Float)
    )
    application_origin: Optional[ApplicationOrigin] = Field(
        default=None, sa_column=Column("applicationOrigin", _application_origin)
    )
    originated_at: Optional[datetime] = Field(
        default=None, sa_column=Column("originatedAt", _TS3)
    )
    internal_assessment_notes: Optional[str] = Field(
        default=None, sa_column=Column("internalAssessmentNotes", Text)
    )
    requirements_summary: Optional[str] = Field(
        default=None, sa_column=Column("requirementsSummary", Text)
    )
    role_summary: Optional[str] = Field(
        default=None, sa_column=Column("roleSummary", Text)
    )
    skills_summary: Optional[str] = Field(
        default=None, sa_column=Column("skillsSummary", Text)
    )
    ai_post_tier: Optional[str] = Field(
        default=None, sa_column=Column("aiPostTier", Text)
    )
    gaps_summary: Optional[str] = Field(
        default=None, sa_column=Column("gapsSummary", Text)
    )
    other_summary: Optional[str] = Field(
        default=None, sa_column=Column("otherSummary", Text)
    )
    tier_summary: Optional[str] = Field(
        default=None, sa_column=Column("tierSummary", Text)
    )
    candidate_summary: Optional[str] = Field(
        default=None, sa_column=Column("candidateSummary", Text)
    )
    client_decision: Optional[str] = Field(
        default=None, sa_column=Column("clientDecision", Text)
    )
    client_feedback: Optional[str] = Field(
        default=None, sa_column=Column("clientFeedback", Text)
    )

    candidate: Optional[Candidate] = Relationship(
        sa_relationship=relationship("Candidate", back_populates="applications")
    )
    role: Optional[Role] = Relationship(
        sa_relationship=relationship("Role", back_populates="applications")
    )

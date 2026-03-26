from __future__ import annotations

import enum


class ApplicationOrigin(str, enum.Enum):
    DASHBOARD = "DASHBOARD"
    AI_WORKFLOW = "AI_WORKFLOW"


class EntityType(str, enum.Enum):
    CANDIDATE = "CANDIDATE"
    ROLE = "ROLE"


class MessageDirection(str, enum.Enum):
    INBOUND = "INBOUND"
    OUTBOUND = "OUTBOUND"


class RemoteScope(str, enum.Enum):
    NONE = "NONE"
    WORLDWIDE = "WORLDWIDE"
    LIMITED = "LIMITED"


class SlackStatus(str, enum.Enum):
    NOT_SENT = "NOT_SENT"
    SENT = "SENT"
    FAILED = "FAILED"


class SyncStatus(str, enum.Enum):
    success = "success"
    failed = "failed"
    partial = "partial"


class SyncType(str, enum.Enum):
    webhook = "webhook"
    reconciliation = "reconciliation"
    webhook_refresh = "webhook_refresh"


class TaskCategory(str, enum.Enum):
    FOLLOW_UP = "FOLLOW_UP"
    SUBMIT_CANDIDATES = "SUBMIT_CANDIDATES"
    REQUEST_PORTFOLIO = "REQUEST_PORTFOLIO"
    INTERVIEW = "INTERVIEW"
    CLIENT_CHECK = "CLIENT_CHECK"
    TECH_ASSESSMENT = "TECH_ASSESSMENT"
    OTHER = "OTHER"


class TaskOrigin(str, enum.Enum):
    MANUAL = "MANUAL"
    SQUAD_RECOMMENDED = "SQUAD_RECOMMENDED"


class TaskPriority(str, enum.Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    URGENT = "URGENT"


class UpdateType(str, enum.Enum):
    CANDIDATE_STATUS = "CANDIDATE_STATUS"
    ROLE_LIFECYCLE = "ROLE_LIFECYCLE"
    MANUAL_UPDATE = "MANUAL_UPDATE"


class UserType(str, enum.Enum):
    RECRUITER = "RECRUITER"
    SQUAD_MEMBER = "SQUAD_MEMBER"
    ADMIN = "ADMIN"


class WorkArrangement(str, enum.Enum):
    ONSITE = "ONSITE"
    REMOTE = "REMOTE"
    HYBRID = "HYBRID"

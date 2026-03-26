-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

-- DROP TYPE public."ApplicationOrigin";

CREATE TYPE public."ApplicationOrigin" AS ENUM (
	'DASHBOARD',
	'AI_WORKFLOW');

-- DROP TYPE public."EntityType";

CREATE TYPE public."EntityType" AS ENUM (
	'CANDIDATE',
	'ROLE');

-- DROP TYPE public."MessageDirection";

CREATE TYPE public."MessageDirection" AS ENUM (
	'INBOUND',
	'OUTBOUND');

-- DROP TYPE public."RemoteScope";

CREATE TYPE public."RemoteScope" AS ENUM (
	'NONE',
	'WORLDWIDE',
	'LIMITED');

-- DROP TYPE public."SlackStatus";

CREATE TYPE public."SlackStatus" AS ENUM (
	'NOT_SENT',
	'SENT',
	'FAILED');

-- DROP TYPE public."SyncStatus";

CREATE TYPE public."SyncStatus" AS ENUM (
	'success',
	'failed',
	'partial');

-- DROP TYPE public."SyncType";

CREATE TYPE public."SyncType" AS ENUM (
	'webhook',
	'reconciliation',
	'webhook_refresh');

-- DROP TYPE public."TaskCategory";

CREATE TYPE public."TaskCategory" AS ENUM (
	'FOLLOW_UP',
	'SUBMIT_CANDIDATES',
	'REQUEST_PORTFOLIO',
	'INTERVIEW',
	'CLIENT_CHECK',
	'TECH_ASSESSMENT',
	'OTHER');

-- DROP TYPE public."TaskOrigin";

CREATE TYPE public."TaskOrigin" AS ENUM (
	'MANUAL',
	'SQUAD_RECOMMENDED');

-- DROP TYPE public."TaskPriority";

CREATE TYPE public."TaskPriority" AS ENUM (
	'LOW',
	'MEDIUM',
	'HIGH',
	'URGENT');

-- DROP TYPE public."UpdateType";

CREATE TYPE public."UpdateType" AS ENUM (
	'CANDIDATE_STATUS',
	'ROLE_LIFECYCLE',
	'MANUAL_UPDATE');

-- DROP TYPE public."UserType";

CREATE TYPE public."UserType" AS ENUM (
	'RECRUITER',
	'SQUAD_MEMBER',
	'ADMIN');

-- DROP TYPE public."WorkArrangement";

CREATE TYPE public."WorkArrangement" AS ENUM (
	'ONSITE',
	'REMOTE',
	'HYBRID');
-- public."Company" definition

-- Drop table

-- DROP TABLE public."Company";

CREATE TABLE public."Company" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	"name" text NULL,
	"companyOverview" text NULL,
	"companyUrl" text NULL,
	about text NULL,
	"clientOwner" text NULL,
	"communicationChannel" text NULL,
	"trackingChannel" text NULL,
	created timestamp(3) NULL,
	"lastSyncedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	segment text NULL,
	"clientPriority" text NULL,
	"clientConfidence" text NULL,
	airtable_id text NULL,
	"deletedAt" timestamp(3) NULL,
	CONSTRAINT "Company_pkey" PRIMARY KEY (id)
);
CREATE INDEX "Company_airtable_id_idx" ON public."Company" USING btree (airtable_id);
CREATE UNIQUE INDEX "Company_airtable_id_key" ON public."Company" USING btree (airtable_id);
CREATE INDEX "Company_name_idx" ON public."Company" USING btree (name);
CREATE INDEX "Company_segment_idx" ON public."Company" USING btree (segment);
CREATE UNIQUE INDEX "Company_whalesync_postgres_id_key" ON public."Company" USING btree (whalesync_postgres_id);
ALTER TABLE public."Company" ENABLE ROW LEVEL SECURITY;


-- public."Conversation" definition

-- Drop table

-- DROP TABLE public."Conversation";

CREATE TABLE public."Conversation" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"channelId" text NULL,
	"channelName" text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "Conversation_pkey" PRIMARY KEY (id)
);
ALTER TABLE public."Conversation" ENABLE ROW LEVEL SECURITY;


-- public."Location" definition

-- Drop table

-- DROP TABLE public."Location";

CREATE TABLE public."Location" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	city text NULL,
	region text NULL,
	country text NULL,
	"countryCode" text NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	continent text NULL,
	CONSTRAINT "Location_pkey" PRIMARY KEY (id)
);
CREATE INDEX "Location_city_idx" ON public."Location" USING btree (city);
CREATE UNIQUE INDEX "Location_city_region_country_countryCode_key" ON public."Location" USING btree (city, region, country, "countryCode");
CREATE INDEX "Location_countryCode_idx" ON public."Location" USING btree ("countryCode");
CREATE INDEX "Location_country_idx" ON public."Location" USING btree (country);
CREATE INDEX "Location_region_idx" ON public."Location" USING btree (region);
CREATE INDEX location_country_code_idx ON public."Location" USING btree ("countryCode");
ALTER TABLE public."Location" ENABLE ROW LEVEL SECURITY;


-- public."Skill" definition

-- Drop table

-- DROP TABLE public."Skill";

CREATE TABLE public."Skill" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	"name" text NULL,
	"lastSyncedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	airtable_id text NULL,
	"deletedAt" timestamp(3) NULL,
	aliases _text DEFAULT ARRAY[]::text[] NULL,
	"impliedSkills" _text DEFAULT ARRAY[]::text[] NULL,
	CONSTRAINT "Skill_pkey" PRIMARY KEY (id)
);
CREATE INDEX "Skill_airtable_id_idx" ON public."Skill" USING btree (airtable_id);
CREATE UNIQUE INDEX "Skill_airtable_id_key" ON public."Skill" USING btree (airtable_id);
CREATE INDEX "Skill_name_idx" ON public."Skill" USING btree (name);
CREATE UNIQUE INDEX "Skill_whalesync_postgres_id_key" ON public."Skill" USING btree (whalesync_postgres_id);
ALTER TABLE public."Skill" ENABLE ROW LEVEL SECURITY;


-- public."SlackUserCache" definition

-- Drop table

-- DROP TABLE public."SlackUserCache";

CREATE TABLE public."SlackUserCache" (
	email text NOT NULL,
	"slackUserId" text NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "SlackUserCache_pkey" PRIMARY KEY (email)
);
ALTER TABLE public."SlackUserCache" ENABLE ROW LEVEL SECURITY;


-- public."SyncLog" definition

-- Drop table

-- DROP TABLE public."SyncLog";

CREATE TABLE public."SyncLog" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"syncType" public."SyncType" NOT NULL,
	status public."SyncStatus" NOT NULL,
	"recordsProcessed" int4 DEFAULT 0 NOT NULL,
	"startedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"completedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"errorDetails" jsonb NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "SyncLog_pkey" PRIMARY KEY (id)
);
CREATE INDEX "SyncLog_completedAt_idx" ON public."SyncLog" USING btree ("completedAt" DESC);
CREATE INDEX "SyncLog_syncType_status_idx" ON public."SyncLog" USING btree ("syncType", status);
ALTER TABLE public."SyncLog" ENABLE ROW LEVEL SECURITY;


-- public."SyncMetadata" definition

-- Drop table

-- DROP TABLE public."SyncMetadata";

CREATE TABLE public."SyncMetadata" (
	"key" text NOT NULL,
	value text NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "SyncMetadata_pkey" PRIMARY KEY (key)
);
ALTER TABLE public."SyncMetadata" ENABLE ROW LEVEL SECURITY;


-- public."User" definition

-- Drop table

-- DROP TABLE public."User";

CREATE TABLE public."User" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	email text NULL,
	"name" text NULL,
	"slackUserId" text NULL,
	"userType" public."UserType" DEFAULT 'RECRUITER'::"UserType" NULL,
	"lastLogin" timestamp(3) NULL,
	active bool DEFAULT true NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	"priorityOpportunities_fk_Role" _text DEFAULT ARRAY[]::text[] NULL,
	airtable_id text NULL,
	"priorityOpportunities_fk_Role_airtable" _text DEFAULT ARRAY[]::text[] NULL,
	"deletedAt" timestamp(3) NULL,
	"askedPreferences" bool DEFAULT false NULL,
	"locationPreference" _text DEFAULT ARRAY[]::text[] NULL,
	"otherPreferences" _text DEFAULT ARRAY[]::text[] NULL,
	"recruiterPreference" text NULL,
	"rolePreferences" _text DEFAULT ARRAY[]::text[] NULL,
	CONSTRAINT "User_pkey" PRIMARY KEY (id)
);
CREATE INDEX "User_airtable_id_idx" ON public."User" USING btree (airtable_id);
CREATE UNIQUE INDEX "User_airtable_id_key" ON public."User" USING btree (airtable_id);
CREATE INDEX "User_email_idx" ON public."User" USING btree (email);
CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);
CREATE UNIQUE INDEX "User_slackUserId_key" ON public."User" USING btree ("slackUserId");
CREATE INDEX "User_userType_active_idx" ON public."User" USING btree ("userType", active);
CREATE INDEX "User_userType_idx" ON public."User" USING btree ("userType");
CREATE INDEX "User_whalesync_postgres_id_idx" ON public."User" USING btree (whalesync_postgres_id);
CREATE UNIQUE INDEX "User_whalesync_postgres_id_key" ON public."User" USING btree (whalesync_postgres_id);
ALTER TABLE public."User" ENABLE ROW LEVEL SECURITY;


-- public."WebhookEvent" definition

-- Drop table

-- DROP TABLE public."WebhookEvent";

CREATE TABLE public."WebhookEvent" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"webhookId" text NOT NULL,
	payload jsonb NOT NULL,
	processed bool DEFAULT false NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "WebhookEvent_pkey" PRIMARY KEY (id)
);
CREATE INDEX "WebhookEvent_processed_idx" ON public."WebhookEvent" USING btree (processed);
CREATE INDEX "WebhookEvent_webhookId_idx" ON public."WebhookEvent" USING btree ("webhookId");
ALTER TABLE public."WebhookEvent" ENABLE ROW LEVEL SECURITY;


-- public."WebhookRegistration" definition

-- Drop table

-- DROP TABLE public."WebhookRegistration";

CREATE TABLE public."WebhookRegistration" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"webhookId" text NOT NULL,
	"baseId" text NOT NULL,
	"notificationUrl" text NOT NULL,
	"expiresAt" timestamp(3) NOT NULL,
	"lastRefreshedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"macSecretBase64" text NULL,
	"tableId" text NULL,
	"tableName" text NULL,
	"lastProcessedTransaction" int4 DEFAULT 0 NOT NULL,
	CONSTRAINT "WebhookRegistration_pkey" PRIMARY KEY (id)
);
CREATE INDEX "WebhookRegistration_expiresAt_idx" ON public."WebhookRegistration" USING btree ("expiresAt");
CREATE INDEX "WebhookRegistration_webhookId_idx" ON public."WebhookRegistration" USING btree ("webhookId");
CREATE UNIQUE INDEX "WebhookRegistration_webhookId_key" ON public."WebhookRegistration" USING btree ("webhookId");
ALTER TABLE public."WebhookRegistration" ENABLE ROW LEVEL SECURITY;


-- public."Candidate" definition

-- Drop table

-- DROP TABLE public."Candidate";

CREATE TABLE public."Candidate" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	"name" text NULL,
	email text NULL,
	"location" text NULL,
	"linkedIn" text NULL,
	"gitHub" text NULL,
	cv text NULL,
	"resumeAttachment" text NULL,
	"salaryExpectations" text NULL,
	"compMin" text NULL,
	description text NULL,
	"previousRoles" text NULL,
	"noticePeriod" text NULL,
	"allSkills" _text DEFAULT ARRAY[]::text[] NULL,
	"allSkillsStructured" text NULL,
	"techStack1" text NULL,
	"techStack1Xp" int4 NULL,
	"techStack2" text NULL,
	"techStack2Xp" int4 NULL,
	"techStack3" text NULL,
	"techStack3Xp" int4 NULL,
	"sellingPoints" text NULL,
	"otherNotes" text NULL,
	"addtlComments" text NULL,
	"telegramForComms" text NULL,
	timezone text NULL,
	"xpYears" int4 NULL,
	"technicalRating" text NULL,
	sponsorship text NULL,
	"fitConfidence" text NULL,
	"userId" text NULL,
	"lastSyncedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"submittedAt" timestamp(3) NULL,
	"updatedAt" timestamp(3) NULL,
	"stageWithSquad" text NULL,
	seniority text NULL,
	"devType" text NULL,
	"availabilityStatus" text NULL,
	quality text NULL,
	"otherDocs" text NULL,
	"technicalCompleted" int4 NULL,
	airtable_id text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"userId_airtable" text NULL,
	"stageWithSquadUpdatedAt" timestamp(3) NULL,
	"techStackToBeTested" text NULL,
	"opportunityId" text NULL,
	"roleOpportunity" text NULL,
	"deletedAt" timestamp(3) NULL,
	continent text NULL,
	available text NULL,
	stage text NULL,
	country text NULL,
	"cvRawContent" text NULL,
	CONSTRAINT "Candidate_pkey" PRIMARY KEY (id),
	CONSTRAINT "Candidate_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Candidate_airtable_id_idx" ON public."Candidate" USING btree (airtable_id);
CREATE UNIQUE INDEX "Candidate_airtable_id_key" ON public."Candidate" USING btree (airtable_id);
CREATE INDEX "Candidate_availabilityStatus_idx" ON public."Candidate" USING btree ("availabilityStatus");
CREATE INDEX "Candidate_email_idx" ON public."Candidate" USING btree (email);
CREATE INDEX "Candidate_name_idx" ON public."Candidate" USING btree (name);
CREATE INDEX "Candidate_stageWithSquad_idx" ON public."Candidate" USING btree ("stageWithSquad");
CREATE INDEX "Candidate_submittedAt_idx" ON public."Candidate" USING btree ("submittedAt");
CREATE INDEX "Candidate_userId_stageWithSquad_idx" ON public."Candidate" USING btree ("userId", "stageWithSquad");
CREATE INDEX "Candidate_userId_submittedAt_idx" ON public."Candidate" USING btree ("userId", "submittedAt" DESC);
CREATE UNIQUE INDEX "Candidate_whalesync_postgres_id_key" ON public."Candidate" USING btree (whalesync_postgres_id);
ALTER TABLE public."Candidate" ENABLE ROW LEVEL SECURITY;


-- public."ChannelMapping" definition

-- Drop table

-- DROP TABLE public."ChannelMapping";

CREATE TABLE public."ChannelMapping" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"channelId" text NOT NULL,
	"channelName" text NULL,
	"userId" text NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	"lastActivity" timestamp(3) NULL,
	CONSTRAINT "ChannelMapping_pkey" PRIMARY KEY (id),
	CONSTRAINT "ChannelMapping_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "ChannelMapping_channelId_idx" ON public."ChannelMapping" USING btree ("channelId");
CREATE UNIQUE INDEX "ChannelMapping_channelId_key" ON public."ChannelMapping" USING btree ("channelId");
CREATE INDEX "ChannelMapping_userId_idx" ON public."ChannelMapping" USING btree ("userId");
ALTER TABLE public."ChannelMapping" ENABLE ROW LEVEL SECURITY;


-- public."ClientFeedbackToken" definition

-- Drop table

-- DROP TABLE public."ClientFeedbackToken";

CREATE TABLE public."ClientFeedbackToken" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"token" text NOT NULL,
	"createdBy" text NOT NULL,
	"expiresAt" timestamp(3) NOT NULL,
	"viewCount" int4 DEFAULT 0 NOT NULL,
	"lastViewedAt" timestamp(3) NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	"clientAirtableId" text NOT NULL,
	CONSTRAINT "ClientFeedbackToken_pkey" PRIMARY KEY (id),
	CONSTRAINT "ClientFeedbackToken_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "ClientFeedbackToken_clientAirtableId_idx" ON public."ClientFeedbackToken" USING btree ("clientAirtableId");
CREATE INDEX "ClientFeedbackToken_createdBy_idx" ON public."ClientFeedbackToken" USING btree ("createdBy");
CREATE INDEX "ClientFeedbackToken_expiresAt_idx" ON public."ClientFeedbackToken" USING btree ("expiresAt");
CREATE INDEX "ClientFeedbackToken_token_idx" ON public."ClientFeedbackToken" USING btree (token);
CREATE UNIQUE INDEX "ClientFeedbackToken_token_key" ON public."ClientFeedbackToken" USING btree (token);
ALTER TABLE public."ClientFeedbackToken" ENABLE ROW LEVEL SECURITY;


-- public."Comment" definition

-- Drop table

-- DROP TABLE public."Comment";

CREATE TABLE public."Comment" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"text" text NOT NULL,
	"candidateId" text NULL,
	"userId" text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "Comment_pkey" PRIMARY KEY (id),
	CONSTRAINT "Comment_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES public."Candidate"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
ALTER TABLE public."Comment" ENABLE ROW LEVEL SECURITY;


-- public."ConversationParticipant" definition

-- Drop table

-- DROP TABLE public."ConversationParticipant";

CREATE TABLE public."ConversationParticipant" (
	"conversationId" text NOT NULL,
	"userId" text NOT NULL,
	"joinedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "ConversationParticipant_pkey" PRIMARY KEY ("conversationId", "userId"),
	CONSTRAINT "ConversationParticipant_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES public."Conversation"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "ConversationParticipant_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
ALTER TABLE public."ConversationParticipant" ENABLE ROW LEVEL SECURITY;


-- public."InterviewFeedback" definition

-- Drop table

-- DROP TABLE public."InterviewFeedback";

CREATE TABLE public."InterviewFeedback" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"candidateId" text NOT NULL,
	"candidateName" text NOT NULL,
	rating text NULL,
	"problemSolvingApproach" text NULL,
	"wouldWorkTogether" text NULL,
	"workTogetherExplanation" text NULL,
	"experienceExplanation" text NULL,
	"otherThoughts" text NULL,
	top10 text NULL,
	airtable_id text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "InterviewFeedback_pkey" PRIMARY KEY (id),
	CONSTRAINT "InterviewFeedback_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES public."Candidate"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE UNIQUE INDEX "InterviewFeedback_airtable_id_key" ON public."InterviewFeedback" USING btree (airtable_id);
CREATE INDEX "InterviewFeedback_candidateId_idx" ON public."InterviewFeedback" USING btree ("candidateId");
CREATE INDEX "InterviewFeedback_candidateName_idx" ON public."InterviewFeedback" USING btree ("candidateName");
ALTER TABLE public."InterviewFeedback" ENABLE ROW LEVEL SECURITY;


-- public."Message" definition

-- Drop table

-- DROP TABLE public."Message";

CREATE TABLE public."Message" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"conversationId" text NOT NULL,
	direction public."MessageDirection" NOT NULL,
	"text" text NOT NULL,
	"slackUserId" text NULL,
	"slackTs" text NULL,
	"slackChannelId" text NULL,
	"userId" text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "Message_pkey" PRIMARY KEY (id),
	CONSTRAINT "Message_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES public."Conversation"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "Message_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Message_conversationId_createdAt_idx" ON public."Message" USING btree ("conversationId", "createdAt");
CREATE INDEX "Message_userId_idx" ON public."Message" USING btree ("userId");
ALTER TABLE public."Message" ENABLE ROW LEVEL SECURITY;


-- public."Notification" definition

-- Drop table

-- DROP TABLE public."Notification";

CREATE TABLE public."Notification" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"type" text NOT NULL,
	message text NOT NULL,
	"read" bool DEFAULT false NOT NULL,
	"userId" text NULL,
	"sentAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	metadata jsonb NULL,
	"slackSentAt" timestamp(3) NULL,
	"slackStatus" public."SlackStatus" DEFAULT 'NOT_SENT'::"SlackStatus" NOT NULL,
	CONSTRAINT "Notification_pkey" PRIMARY KEY (id),
	CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Notification_userId_idx" ON public."Notification" USING btree ("userId");
CREATE INDEX "Notification_userId_read_idx" ON public."Notification" USING btree ("userId", read);
CREATE INDEX "Notification_userId_read_sentAt_idx" ON public."Notification" USING btree ("userId", read, "sentAt");
ALTER TABLE public."Notification" ENABLE ROW LEVEL SECURITY;


-- public."Role" definition

-- Drop table

-- DROP TABLE public."Role";

CREATE TABLE public."Role" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	"ref" text NULL,
	"role" text NULL,
	"enhancedJd" text NULL,
	"rejectionsLog" text NULL,
	"requiredLocation" text NULL,
	comp text NULL,
	"totalSharedWithClient" int4 NULL,
	"internalId" int4 NULL,
	"companyId" text NULL,
	"lastSyncedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	"statusInternal" text NULL,
	"skills_fk_Skill" _text DEFAULT ARRAY[]::text[] NULL,
	"maxCompensation" text NULL,
	"requiredOverlap" text NULL,
	"rolePriority" text NULL,
	airtable_id text NULL,
	"companyId_airtable" text NULL,
	"skills_fk_Skill_airtable" _text DEFAULT ARRAY[]::text[] NULL,
	"keyIndicators" _text DEFAULT ARRAY[]::text[] NULL,
	"indepRecruiters" text NULL,
	"isAcceptingNewSubmissions" bool DEFAULT true NULL,
	"deletedAt" timestamp(3) NULL,
	continents text NULL,
	"requirementsStructured" text NULL,
	"findCandidatesRunId" text NULL,
	"internalEvaluation" text NULL,
	countries text NULL,
	"roleType" text NULL,
	CONSTRAINT "Role_pkey" PRIMARY KEY (id),
	CONSTRAINT "Role_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES public."Company"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Role_airtable_id_idx" ON public."Role" USING btree (airtable_id);
CREATE UNIQUE INDEX "Role_airtable_id_key" ON public."Role" USING btree (airtable_id);
CREATE INDEX "Role_companyId_idx" ON public."Role" USING btree ("companyId");
CREATE INDEX "Role_companyId_statusInternal_idx" ON public."Role" USING btree ("companyId", "statusInternal");
CREATE INDEX "Role_internalId_idx" ON public."Role" USING btree ("internalId");
CREATE INDEX "Role_ref_idx" ON public."Role" USING btree (ref);
CREATE INDEX "Role_statusInternal_idx" ON public."Role" USING btree ("statusInternal");
CREATE INDEX "Role_statusInternal_internalId_idx" ON public."Role" USING btree ("statusInternal", "internalId");
CREATE UNIQUE INDEX "Role_whalesync_postgres_id_key" ON public."Role" USING btree (whalesync_postgres_id);
ALTER TABLE public."Role" ENABLE ROW LEVEL SECURITY;


-- public."RoleLocation" definition

-- Drop table

-- DROP TABLE public."RoleLocation";

CREATE TABLE public."RoleLocation" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"roleId" text NOT NULL,
	"locationId" text NULL,
	"workArrangement" public."WorkArrangement" NOT NULL,
	"remoteScope" public."RemoteScope" DEFAULT 'NONE'::"RemoteScope" NOT NULL,
	"eligibleCountries" _text DEFAULT ARRAY[]::text[] NULL,
	"needsLocationReview" bool DEFAULT false NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	CONSTRAINT "RoleLocation_pkey" PRIMARY KEY (id),
	CONSTRAINT "RoleLocation_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES public."Location"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "RoleLocation_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "RoleLocation_locationId_idx" ON public."RoleLocation" USING btree ("locationId");
CREATE INDEX "RoleLocation_remoteScope_idx" ON public."RoleLocation" USING btree ("remoteScope");
CREATE INDEX "RoleLocation_roleId_idx" ON public."RoleLocation" USING btree ("roleId");
CREATE UNIQUE INDEX "RoleLocation_roleId_locationId_key" ON public."RoleLocation" USING btree ("roleId", "locationId");
CREATE INDEX "RoleLocation_workArrangement_idx" ON public."RoleLocation" USING btree ("workArrangement");
CREATE INDEX "RoleLocation_workArrangement_remoteScope_idx" ON public."RoleLocation" USING btree ("workArrangement", "remoteScope");
ALTER TABLE public."RoleLocation" ENABLE ROW LEVEL SECURITY;


-- public."SavedFilterView" definition

-- Drop table

-- DROP TABLE public."SavedFilterView";

CREATE TABLE public."SavedFilterView" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"userId" text NOT NULL,
	"name" text NOT NULL,
	"entityType" text NOT NULL,
	config jsonb NOT NULL,
	"isDefault" bool DEFAULT false NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "SavedFilterView_pkey" PRIMARY KEY (id),
	CONSTRAINT "SavedFilterView_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "SavedFilterView_userId_entityType_idx" ON public."SavedFilterView" USING btree ("userId", "entityType");
CREATE UNIQUE INDEX "SavedFilterView_userId_entityType_name_key" ON public."SavedFilterView" USING btree ("userId", "entityType", name);
ALTER TABLE public."SavedFilterView" ENABLE ROW LEVEL SECURITY;


-- public."SavedRole" definition

-- Drop table

-- DROP TABLE public."SavedRole";

CREATE TABLE public."SavedRole" (
	"userId" text NOT NULL,
	"roleId" text NOT NULL,
	"savedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	notes text NULL,
	CONSTRAINT "SavedRole_pkey" PRIMARY KEY ("userId", "roleId"),
	CONSTRAINT "SavedRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "SavedRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
ALTER TABLE public."SavedRole" ENABLE ROW LEVEL SECURITY;


-- public."Task" definition

-- Drop table

-- DROP TABLE public."Task";

CREATE TABLE public."Task" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"type" text NOT NULL,
	description text NULL,
	category public."TaskCategory" DEFAULT 'OTHER'::"TaskCategory" NOT NULL,
	priority public."TaskPriority" DEFAULT 'MEDIUM'::"TaskPriority" NOT NULL,
	"dueDate" timestamp(3) NULL,
	completed bool DEFAULT false NOT NULL,
	"completedAt" timestamp(3) NULL,
	"userId" text NULL,
	"relatedCandidateId" text NULL,
	"roleId" text NULL,
	"automationType" text NULL,
	"triggerTimestamp" timestamp(3) NULL,
	"followUpRule" text NULL,
	"lastFollowUp" timestamp(3) NULL,
	"nextFollowUpAt" timestamp(3) NULL,
	origin public."TaskOrigin" DEFAULT 'MANUAL'::"TaskOrigin" NOT NULL,
	"rank" int4 NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	"lastNotifiedAt" timestamp(3) NULL,
	CONSTRAINT "Task_pkey" PRIMARY KEY (id),
	CONSTRAINT "Task_relatedCandidateId_fkey" FOREIGN KEY ("relatedCandidateId") REFERENCES public."Candidate"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "Task_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "Task_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Task_automationType_triggerTimestamp_idx" ON public."Task" USING btree ("automationType", "triggerTimestamp");
CREATE INDEX "Task_completed_dueDate_idx" ON public."Task" USING btree (completed, "dueDate");
CREATE INDEX "Task_nextFollowUpAt_idx" ON public."Task" USING btree ("nextFollowUpAt");
CREATE INDEX "Task_relatedCandidateId_completed_dueDate_idx" ON public."Task" USING btree ("relatedCandidateId", completed, "dueDate");
CREATE INDEX "Task_relatedCandidateId_roleId_completed_dueDate_idx" ON public."Task" USING btree ("relatedCandidateId", "roleId", completed, "dueDate");
CREATE INDEX "Task_roleId_completed_idx" ON public."Task" USING btree ("roleId", completed);
CREATE INDEX "Task_userId_completed_rank_idx" ON public."Task" USING btree ("userId", completed, rank);
ALTER TABLE public."Task" ENABLE ROW LEVEL SECURITY;


-- public."TaskComment" definition

-- Drop table

-- DROP TABLE public."TaskComment";

CREATE TABLE public."TaskComment" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"text" text NOT NULL,
	"taskId" text NOT NULL,
	"userId" text NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "TaskComment_pkey" PRIMARY KEY (id),
	CONSTRAINT "TaskComment_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public."Task"(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "TaskComment_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "TaskComment_taskId_createdAt_idx" ON public."TaskComment" USING btree ("taskId", "createdAt");
CREATE INDEX "TaskComment_userId_idx" ON public."TaskComment" USING btree ("userId");
ALTER TABLE public."TaskComment" ENABLE ROW LEVEL SECURITY;


-- public."Update" definition

-- Drop table

-- DROP TABLE public."Update";

CREATE TABLE public."Update" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"type" public."UpdateType" NOT NULL,
	"subType" text NULL,
	"entityType" public."EntityType" NOT NULL,
	"entityId" text NOT NULL,
	"candidateId" text NULL,
	"roleId" text NULL,
	title text NOT NULL,
	"content" text NULL,
	metadata jsonb NULL,
	"authorId" text NULL,
	"isRead" bool DEFAULT false NOT NULL,
	"isArchived" bool DEFAULT false NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	CONSTRAINT "Update_pkey" PRIMARY KEY (id),
	CONSTRAINT "Update_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES public."User"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "Update_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES public."Candidate"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "Update_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "Update_candidateId_idx" ON public."Update" USING btree ("candidateId");
CREATE INDEX "Update_createdAt_idx" ON public."Update" USING btree ("createdAt");
CREATE INDEX "Update_entityType_entityId_idx" ON public."Update" USING btree ("entityType", "entityId");
CREATE INDEX "Update_isArchived_isRead_idx" ON public."Update" USING btree ("isArchived", "isRead");
CREATE INDEX "Update_roleId_idx" ON public."Update" USING btree ("roleId");
CREATE INDEX "Update_type_idx" ON public."Update" USING btree (type);
ALTER TABLE public."Update" ENABLE ROW LEVEL SECURITY;


-- public."UserUpdateRead" definition

-- Drop table

-- DROP TABLE public."UserUpdateRead";

CREATE TABLE public."UserUpdateRead" (
	"userId" text NOT NULL,
	"updateId" text NOT NULL,
	"readAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT "UserUpdateRead_pkey" PRIMARY KEY ("userId", "updateId"),
	CONSTRAINT "UserUpdateRead_updateId_fkey" FOREIGN KEY ("updateId") REFERENCES public."Update"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "UserUpdateRead_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "UserUpdateRead_updateId_idx" ON public."UserUpdateRead" USING btree ("updateId");
CREATE INDEX "UserUpdateRead_userId_idx" ON public."UserUpdateRead" USING btree ("userId");
ALTER TABLE public."UserUpdateRead" ENABLE ROW LEVEL SECURITY;


-- public."CandidateApplication" definition

-- Drop table

-- DROP TABLE public."CandidateApplication";

CREATE TABLE public."CandidateApplication" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	whalesync_postgres_id uuid NULL,
	"candidateId" text NULL,
	"statusUpdatedAt" timestamp(3) NULL,
	"additionalDetails" text NULL,
	"roleId" text NULL,
	"lastSyncedAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NULL,
	"updatedAt" timestamp(3) NULL,
	"internalStatus" text NULL,
	"stageWithClient" text NULL,
	"followUpStatus" text NULL,
	tier text NULL,
	"airtableId" int4 NULL,
	"lastActionTakenAt" timestamp(3) NULL,
	"rateOverride" text NULL,
	airtable_id text NULL,
	"candidateId_airtable" text NULL,
	"roleId_airtable" text NULL,
	"nextStep" text NULL,
	notes text NULL,
	"deletedAt" timestamp(3) NULL,
	"aiInitTier" text NULL,
	"aiInitTierSummary" text NULL,
	"consSummary" text NULL,
	"detailedEvaluationDoc" text NULL,
	"evaluationTimestamp" timestamp(3) NULL,
	"overallSummary" text NULL,
	"prosSummary" text NULL,
	"reasonForInitTierSummary" text NULL,
	"reasonForPostTierSummary" text NULL,
	"summaryScore" text NULL,
	"summaryScoreNumeric" float8 NULL,
	"applicationOrigin" public."ApplicationOrigin" NULL,
	"originatedAt" timestamp(3) NULL,
	"internalAssessmentNotes" text NULL,
	"requirementsSummary" text NULL,
	"roleSummary" text NULL,
	"skillsSummary" text NULL,
	"aiPostTier" text NULL,
	"gapsSummary" text NULL,
	"otherSummary" text NULL,
	"tierSummary" text NULL,
	"candidateSummary" text NULL,
	"clientDecision" text NULL,
	"clientFeedback" text NULL,
	CONSTRAINT "CandidateApplication_pkey" PRIMARY KEY (id),
	CONSTRAINT "CandidateApplication_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES public."Candidate"(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT "CandidateApplication_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "CandidateApplication_airtable_id_idx" ON public."CandidateApplication" USING btree (airtable_id);
CREATE UNIQUE INDEX "CandidateApplication_airtable_id_key" ON public."CandidateApplication" USING btree (airtable_id);
CREATE INDEX "CandidateApplication_applicationOrigin_idx" ON public."CandidateApplication" USING btree ("applicationOrigin");
CREATE INDEX "CandidateApplication_candidateId_idx" ON public."CandidateApplication" USING btree ("candidateId");
CREATE INDEX "CandidateApplication_candidateId_roleId_idx" ON public."CandidateApplication" USING btree ("candidateId", "roleId");
CREATE INDEX "CandidateApplication_internalStatus_idx" ON public."CandidateApplication" USING btree ("internalStatus");
CREATE INDEX "CandidateApplication_internalStatus_lastActionTakenAt_idx" ON public."CandidateApplication" USING btree ("internalStatus", "lastActionTakenAt");
CREATE INDEX "CandidateApplication_roleId_idx" ON public."CandidateApplication" USING btree ("roleId");
CREATE INDEX "CandidateApplication_roleId_internalStatus_idx" ON public."CandidateApplication" USING btree ("roleId", "internalStatus");
CREATE INDEX "CandidateApplication_stageWithClient_idx" ON public."CandidateApplication" USING btree ("stageWithClient");
CREATE UNIQUE INDEX "CandidateApplication_whalesync_postgres_id_key" ON public."CandidateApplication" USING btree (whalesync_postgres_id);
ALTER TABLE public."CandidateApplication" ENABLE ROW LEVEL SECURITY;


-- public."RateAdjustment" definition

-- Drop table

-- DROP TABLE public."RateAdjustment";

CREATE TABLE public."RateAdjustment" (
	id text DEFAULT gen_random_uuid() NOT NULL,
	"recruiterId" text NOT NULL,
	"roleId" text NOT NULL,
	"ratePercent" float8 NOT NULL,
	"createdAt" timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updatedAt" timestamp(3) NOT NULL,
	"createdBy" text NOT NULL,
	CONSTRAINT "RateAdjustment_pkey" PRIMARY KEY (id),
	CONSTRAINT "RateAdjustment_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "RateAdjustment_recruiterId_fkey" FOREIGN KEY ("recruiterId") REFERENCES public."User"(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT "RateAdjustment_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public."Role"(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "RateAdjustment_createdBy_idx" ON public."RateAdjustment" USING btree ("createdBy");
CREATE INDEX "RateAdjustment_recruiterId_idx" ON public."RateAdjustment" USING btree ("recruiterId");
CREATE UNIQUE INDEX "RateAdjustment_recruiterId_roleId_key" ON public."RateAdjustment" USING btree ("recruiterId", "roleId");
CREATE INDEX "RateAdjustment_roleId_idx" ON public."RateAdjustment" USING btree ("roleId");
ALTER TABLE public."RateAdjustment" ENABLE ROW LEVEL SECURITY;



-- DROP FUNCTION public.filter_match(jsonb, jsonb);

CREATE OR REPLACE FUNCTION public.filter_match(row_data jsonb, filter_group jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
  op text;
  filters jsonb;
  col_id text;
  filter_op text;
  filter_val text;
  col_val text;
  i int;
  result boolean;
  child_result boolean;
BEGIN
  IF filter_group IS NULL THEN RETURN true; END IF;

  -- Leaf node (has columnId)
  col_id := filter_group->>'columnId';
  IF col_id IS NOT NULL THEN
    filter_op := filter_group->>'operator';
    filter_val := COALESCE(filter_group->>'value', '');
    col_val := COALESCE(row_data->>col_id, '');

    IF filter_val = '' AND filter_op NOT IN ('empty', 'notEmpty') THEN
      RETURN true;
    END IF;

    RETURN CASE filter_op
      WHEN 'includes'    THEN col_val ILIKE '%' || filter_val || '%'
      WHEN 'notIncludes' THEN col_val NOT ILIKE '%' || filter_val || '%'
      WHEN 'equals'      THEN col_val = filter_val
      WHEN 'notEquals'   THEN col_val != filter_val
      WHEN 'startsWith'  THEN col_val ILIKE filter_val || '%'
      WHEN 'endsWith'    THEN col_val ILIKE '%' || filter_val
      WHEN 'empty'       THEN (row_data->>col_id IS NULL OR col_val = '')
      WHEN 'notEmpty'    THEN (row_data->>col_id IS NOT NULL AND col_val != '')
      WHEN 'gt'          THEN col_val > filter_val
      WHEN 'lt'          THEN col_val < filter_val
      ELSE true
    END;
  END IF;

  -- Group node (has filters array)
  filters := filter_group->'filters';
  IF filters IS NULL THEN RETURN true; END IF;

  op := COALESCE(filter_group->>'operator', 'and');

  IF op = 'or' THEN
    result := false;
    FOR i IN 0..jsonb_array_length(filters) - 1 LOOP
      child_result := filter_match(row_data, filters->i);
      IF child_result THEN RETURN true; END IF;
    END LOOP;
    RETURN false;
  ELSE
    FOR i IN 0..jsonb_array_length(filters) - 1 LOOP
      child_result := filter_match(row_data, filters->i);
      IF NOT child_result THEN RETURN false; END IF;
    END LOOP;
    RETURN true;
  END IF;
END;
$function$
;
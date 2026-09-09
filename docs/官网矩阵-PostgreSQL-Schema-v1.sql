-- 逐鹿未来项目官网矩阵 PostgreSQL Schema 草案
-- Version: v1.0
-- Date: 2026-07-30
--
-- 目的：
-- 1. 明确 MVP 领域边界和关系；
-- 2. 作为正式 migration 设计输入，不应直接用于生产；
-- 3. 状态机、作用域、加密、权限和跨表一致性仍需应用层与测试保证。

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------------------
-- Identity and access
-- ---------------------------------------------------------------------------

CREATE TABLE app_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  display_name text NOT NULL,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('invited', 'active', 'suspended', 'disabled')),
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE roles (
  code text PRIMARY KEY,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO roles (code, name, description) VALUES
  ('system_admin', '系统管理员', '系统配置、权限和紧急操作'),
  ('hq_operator', '总部运营', '总部城市、门店和内容运营'),
  ('content_editor', '内容编辑', 'Brief、草稿和编辑审核'),
  ('fact_reviewer', '事实审核', 'Claim、Evidence 和事实审核'),
  ('seo_reviewer', 'SEO 审核', '搜索质量和索引审核'),
  ('compliance_reviewer', '合规审核', '广告、隐私、未成年人和版权审核'),
  ('publisher', '发布人员', '批准后的排期、发布和回滚'),
  ('region_operator', '城市运营', '授权城市范围内的数据和内容'),
  ('location_operator', '门店运营', '授权门店和本地线索'),
  ('lead_manager', '线索管理员', '权限范围内的线索分配和跟进')
ON CONFLICT (code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Regions and locations
-- ---------------------------------------------------------------------------

CREATE TABLE regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_code text NOT NULL UNIQUE,
  parent_id uuid REFERENCES regions(id) ON DELETE RESTRICT,
  level text NOT NULL
    CHECK (level IN ('country', 'province', 'prefecture', 'county', 'district')),
  name text NOT NULL,
  short_name text,
  slug text NOT NULL,
  full_path text NOT NULL UNIQUE,
  business_priority smallint NOT NULL DEFAULT 0
    CHECK (business_priority BETWEEN 0 AND 100),
  service_status text NOT NULL DEFAULT 'data_only'
    CHECK (
      service_status IN (
        'data_only',
        'serviceable',
        'verified',
        'flagship',
        'paused',
        'retired'
      )
    ),
  index_status text NOT NULL DEFAULT 'not_public'
    CHECK (
      index_status IN (
        'not_public',
        'public_noindex',
        'index_candidate',
        'indexable',
        'paused',
        'retired'
      )
    ),
  readiness_score smallint NOT NULL DEFAULT 0
    CHECK (readiness_score BETWEEN 0 AND 100),
  owner_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  last_verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (parent_id, slug)
);

CREATE INDEX regions_parent_idx ON regions(parent_id);
CREATE INDEX regions_status_idx ON regions(service_status, index_status);
CREATE INDEX regions_priority_idx ON regions(business_priority DESC);

CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id uuid NOT NULL REFERENCES regions(id) ON DELETE RESTRICT,
  slug text NOT NULL UNIQUE,
  public_name text NOT NULL,
  legal_entity_name text,
  location_type text NOT NULL
    CHECK (
      location_type IN (
        'direct_store',
        'partner_school',
        'service_center',
        'regional_office'
      )
    ),
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'active', 'paused', 'closed', 'retired')),
  address_line text,
  longitude numeric(10, 7),
  latitude numeric(10, 7),
  public_phone text,
  public_wechat_asset_id uuid,
  opening_hours jsonb NOT NULL DEFAULT '{}'::jsonb,
  service_description text,
  owner_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  lead_pool_code text,
  last_verified_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX locations_region_idx ON locations(region_id);
CREATE INDEX locations_status_idx ON locations(status);
CREATE INDEX locations_owner_idx ON locations(owner_user_id);

CREATE TABLE location_service_regions (
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  region_id uuid NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
  priority smallint NOT NULL DEFAULT 0,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (location_id, region_id)
);

CREATE INDEX location_service_regions_region_idx
  ON location_service_regions(region_id, priority DESC);

CREATE TABLE user_role_scopes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  role_code text NOT NULL REFERENCES roles(code) ON DELETE RESTRICT,
  scope_type text NOT NULL
    CHECK (scope_type IN ('global', 'region', 'location')),
  region_id uuid REFERENCES regions(id) ON DELETE CASCADE,
  location_id uuid REFERENCES locations(id) ON DELETE CASCADE,
  granted_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (scope_type = 'global' AND region_id IS NULL AND location_id IS NULL)
    OR (scope_type = 'region' AND region_id IS NOT NULL AND location_id IS NULL)
    OR (scope_type = 'location' AND region_id IS NULL AND location_id IS NOT NULL)
  )
);

CREATE UNIQUE INDEX user_role_scopes_unique_idx
  ON user_role_scopes (
    user_id,
    role_code,
    scope_type,
    COALESCE(region_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(location_id, '00000000-0000-0000-0000-000000000000'::uuid)
  );

CREATE TABLE region_readiness_assessments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id uuid NOT NULL REFERENCES regions(id) ON DELETE CASCADE,
  schema_version integer NOT NULL,
  score smallint NOT NULL CHECK (score BETWEEN 0 AND 100),
  required_checks jsonb NOT NULL,
  missing_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  blockers jsonb NOT NULL DEFAULT '[]'::jsonb,
  assessed_by_type text NOT NULL
    CHECK (assessed_by_type IN ('system', 'agent', 'human')),
  assessed_by_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  assessed_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX region_readiness_latest_idx
  ON region_readiness_assessments(region_id, assessed_at DESC);

-- ---------------------------------------------------------------------------
-- Assets, rights, claims, and evidence
-- ---------------------------------------------------------------------------

CREATE TABLE media_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_key text NOT NULL UNIQUE,
  original_filename text NOT NULL,
  mime_type text NOT NULL,
  byte_size bigint NOT NULL CHECK (byte_size >= 0),
  checksum_sha256 text NOT NULL,
  asset_type text NOT NULL
    CHECK (
      asset_type IN (
        'image',
        'video',
        'audio',
        'document',
        'generated_image',
        'generated_video'
      )
    ),
  rights_status text NOT NULL DEFAULT 'pending'
    CHECK (
      rights_status IN (
        'pending',
        'owned',
        'licensed',
        'consented',
        'restricted',
        'expired',
        'rejected'
      )
    ),
  rights_source text,
  rights_expires_at timestamptz,
  ai_generated boolean NOT NULL DEFAULT false,
  ai_label_metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  uploaded_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX media_assets_rights_idx
  ON media_assets(rights_status, rights_expires_at);

CREATE TABLE location_media (
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  asset_id uuid NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
  usage_type text NOT NULL
    CHECK (usage_type IN ('hero', 'gallery', 'team', 'environment', 'qr_code')),
  sort_order integer NOT NULL DEFAULT 0,
  alt_text text,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (location_id, asset_id, usage_type)
);

ALTER TABLE locations
  ADD CONSTRAINT locations_public_wechat_asset_fk
  FOREIGN KEY (public_wechat_asset_id)
  REFERENCES media_assets(id)
  ON DELETE SET NULL;

CREATE TABLE claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_key text NOT NULL UNIQUE,
  statement text NOT NULL,
  approved_wording text,
  prohibited_expansion text,
  scope_type text NOT NULL
    CHECK (scope_type IN ('global', 'brand', 'product', 'region', 'location', 'case')),
  region_id uuid REFERENCES regions(id) ON DELETE CASCADE,
  location_id uuid REFERENCES locations(id) ON DELETE CASCADE,
  risk_level text NOT NULL DEFAULT 'medium'
    CHECK (risk_level IN ('low', 'medium', 'high', 'restricted')),
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'in_review', 'approved', 'expired', 'rejected', 'revoked')),
  valid_from timestamptz,
  valid_until timestamptz,
  owner_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  approved_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (scope_type = 'region' AND region_id IS NOT NULL AND location_id IS NULL)
    OR (scope_type = 'location' AND location_id IS NOT NULL)
    OR (scope_type NOT IN ('region', 'location'))
  )
);

CREATE INDEX claims_status_validity_idx
  ON claims(status, valid_until);
CREATE INDEX claims_scope_idx
  ON claims(scope_type, region_id, location_id);

CREATE TABLE claim_evidence (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE CASCADE,
  evidence_type text NOT NULL
    CHECK (
      evidence_type IN (
        'official_url',
        'contract',
        'authorization',
        'certificate',
        'business_record',
        'case_record',
        'media_consent',
        'other'
      )
    ),
  title text NOT NULL,
  source_url text,
  asset_id uuid REFERENCES media_assets(id) ON DELETE RESTRICT,
  source_organization text,
  retrieved_at timestamptz,
  valid_until timestamptz,
  verification_status text NOT NULL DEFAULT 'pending'
    CHECK (verification_status IN ('pending', 'verified', 'invalid', 'expired')),
  verified_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  verified_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (source_url IS NOT NULL OR asset_id IS NOT NULL)
);

CREATE INDEX claim_evidence_claim_idx ON claim_evidence(claim_id);
CREATE INDEX claim_evidence_validity_idx
  ON claim_evidence(verification_status, valid_until);

-- ---------------------------------------------------------------------------
-- Content and versions
-- ---------------------------------------------------------------------------

CREATE TABLE content_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type text NOT NULL
    CHECK (
      content_type IN (
        'page',
        'region_page',
        'location_page',
        'article',
        'case_study',
        'faq',
        'event',
        'policy'
      )
    ),
  scope_type text NOT NULL
    CHECK (scope_type IN ('global', 'region', 'location')),
  region_id uuid REFERENCES regions(id) ON DELETE RESTRICT,
  location_id uuid REFERENCES locations(id) ON DELETE RESTRICT,
  title text NOT NULL,
  audience text NOT NULL
    CHECK (audience IN ('all', 'family', 'institution', 'partner', 'operator')),
  search_intent text,
  content_cluster text,
  canonical_path text NOT NULL UNIQUE,
  lifecycle_status text NOT NULL DEFAULT 'brief'
    CHECK (
      lifecycle_status IN (
        'brief',
        'drafting',
        'checking',
        'blocked',
        'human_review',
        'rejected',
        'approved',
        'scheduled',
        'published',
        'monitoring',
        'needs_update',
        'archived',
        'rolled_back'
      )
    ),
  index_status text NOT NULL DEFAULT 'noindex'
    CHECK (index_status IN ('noindex', 'index_candidate', 'indexable', 'removed')),
  risk_level text NOT NULL DEFAULT 'medium'
    CHECK (risk_level IN ('low', 'medium', 'high', 'restricted')),
  schema_version integer NOT NULL DEFAULT 1,
  current_version_id uuid,
  published_version_id uuid,
  owner_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (scope_type = 'global' AND region_id IS NULL AND location_id IS NULL)
    OR (scope_type = 'region' AND region_id IS NOT NULL AND location_id IS NULL)
    OR (scope_type = 'location' AND location_id IS NOT NULL)
  )
);

CREATE INDEX content_items_status_idx
  ON content_items(lifecycle_status, index_status);
CREATE INDEX content_items_scope_idx
  ON content_items(scope_type, region_id, location_id);
CREATE INDEX content_items_cluster_idx
  ON content_items(content_cluster);

CREATE TABLE content_briefs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_item_id uuid NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
  brief_version integer NOT NULL,
  objective text NOT NULL,
  target_questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_claim_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
  prohibited_expressions jsonb NOT NULL DEFAULT '[]'::jsonb,
  required_blocks jsonb NOT NULL DEFAULT '[]'::jsonb,
  call_to_action jsonb NOT NULL DEFAULT '{}'::jsonb,
  update_policy jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by_type text NOT NULL
    CHECK (created_by_type IN ('human', 'agent')),
  created_by_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (content_item_id, brief_version)
);

CREATE TABLE content_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_item_id uuid NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
  version_no integer NOT NULL CHECK (version_no > 0),
  base_version_id uuid REFERENCES content_versions(id) ON DELETE SET NULL,
  blocks jsonb NOT NULL,
  seo jsonb NOT NULL DEFAULT '{}'::jsonb,
  structured_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  generation_method text NOT NULL DEFAULT 'human'
    CHECK (generation_method IN ('human', 'ai_assisted', 'ai_generated')),
  content_schema_version integer NOT NULL,
  prompt_version text,
  model_ref text,
  content_hash text NOT NULL,
  change_summary text,
  created_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (content_item_id, version_no)
);

CREATE INDEX content_versions_item_idx
  ON content_versions(content_item_id, version_no DESC);
CREATE INDEX content_versions_hash_idx ON content_versions(content_hash);

ALTER TABLE content_items
  ADD CONSTRAINT content_items_current_version_fk
  FOREIGN KEY (current_version_id)
  REFERENCES content_versions(id)
  ON DELETE SET NULL;

ALTER TABLE content_items
  ADD CONSTRAINT content_items_published_version_fk
  FOREIGN KEY (published_version_id)
  REFERENCES content_versions(id)
  ON DELETE SET NULL;

CREATE TABLE content_version_claims (
  content_version_id uuid NOT NULL
    REFERENCES content_versions(id) ON DELETE CASCADE,
  claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE RESTRICT,
  block_key text NOT NULL DEFAULT '',
  usage_note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (content_version_id, claim_id, block_key)
);

CREATE INDEX content_version_claims_claim_idx
  ON content_version_claims(claim_id);

CREATE TABLE content_version_assets (
  content_version_id uuid NOT NULL
    REFERENCES content_versions(id) ON DELETE CASCADE,
  asset_id uuid NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
  block_key text NOT NULL,
  usage_type text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (content_version_id, asset_id, block_key)
);

-- ---------------------------------------------------------------------------
-- AI runs, findings, reviews, and approvals
-- ---------------------------------------------------------------------------

CREATE TABLE ai_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_name text NOT NULL,
  workflow_version text NOT NULL,
  content_item_id uuid REFERENCES content_items(id) ON DELETE SET NULL,
  content_version_id uuid REFERENCES content_versions(id) ON DELETE SET NULL,
  region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  location_id uuid REFERENCES locations(id) ON DELETE SET NULL,
  run_status text NOT NULL
    CHECK (
      run_status IN (
        'queued',
        'running',
        'waiting_approval',
        'completed',
        'failed',
        'cancelled',
        'budget_exceeded'
      )
    ),
  risk_level text NOT NULL
    CHECK (risk_level IN ('low', 'medium', 'high', 'restricted')),
  model_provider text NOT NULL,
  model_name text NOT NULL,
  prompt_version text NOT NULL,
  output_schema_version integer NOT NULL,
  trace_id text,
  input_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
  output_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
  pii_redacted boolean NOT NULL DEFAULT true,
  input_tokens bigint,
  output_tokens bigint,
  estimated_cost numeric(14, 6),
  error_code text,
  error_message_redacted text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ai_runs_workflow_idx
  ON ai_runs(workflow_name, workflow_version, created_at DESC);
CREATE INDEX ai_runs_content_idx
  ON ai_runs(content_item_id, content_version_id);
CREATE INDEX ai_runs_status_idx ON ai_runs(run_status, created_at DESC);

CREATE TABLE ai_findings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ai_run_id uuid NOT NULL REFERENCES ai_runs(id) ON DELETE CASCADE,
  content_version_id uuid REFERENCES content_versions(id) ON DELETE CASCADE,
  category text NOT NULL
    CHECK (
      category IN (
        'fact',
        'seo',
        'compliance',
        'privacy',
        'copyright',
        'quality',
        'security'
      )
    ),
  severity text NOT NULL
    CHECK (severity IN ('info', 'warning', 'blocker')),
  code text NOT NULL,
  block_key text,
  message text NOT NULL,
  evidence jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'accepted', 'resolved', 'false_positive')),
  resolved_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  resolution_note text,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ai_findings_open_idx
  ON ai_findings(content_version_id, severity, status);

CREATE TABLE content_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_version_id uuid NOT NULL
    REFERENCES content_versions(id) ON DELETE CASCADE,
  review_type text NOT NULL
    CHECK (review_type IN ('fact', 'seo', 'compliance', 'editorial')),
  reviewer_type text NOT NULL
    CHECK (reviewer_type IN ('human', 'agent', 'system')),
  reviewer_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  ai_run_id uuid REFERENCES ai_runs(id) ON DELETE SET NULL,
  verdict text NOT NULL
    CHECK (verdict IN ('pass', 'pass_with_notes', 'changes_requested', 'blocked')),
  findings jsonb NOT NULL DEFAULT '[]'::jsonb,
  reviewed_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (reviewer_type = 'human' AND reviewer_user_id IS NOT NULL)
    OR (reviewer_type = 'agent' AND ai_run_id IS NOT NULL)
    OR (reviewer_type = 'system')
  )
);

CREATE INDEX content_reviews_version_idx
  ON content_reviews(content_version_id, review_type, reviewed_at DESC);

CREATE TABLE approval_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action_type text NOT NULL
    CHECK (
      action_type IN (
        'publish_content',
        'change_index_status',
        'change_location_contact',
        'approve_high_risk_claim',
        'delete_content',
        'bulk_redirect'
      )
    ),
  target_type text NOT NULL
    CHECK (target_type IN ('content_version', 'content_item', 'region', 'location', 'claim')),
  target_id uuid NOT NULL,
  risk_level text NOT NULL
    CHECK (risk_level IN ('low', 'medium', 'high', 'restricted')),
  requested_by_type text NOT NULL
    CHECK (requested_by_type IN ('human', 'agent', 'system')),
  requested_by_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  requested_by_ai_run_id uuid REFERENCES ai_runs(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'expired')),
  reason text NOT NULL,
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz
);

CREATE INDEX approval_requests_pending_idx
  ON approval_requests(status, action_type, created_at);

CREATE TABLE approval_decisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  approval_request_id uuid NOT NULL
    REFERENCES approval_requests(id) ON DELETE CASCADE,
  decision text NOT NULL CHECK (decision IN ('approve', 'reject')),
  decided_by uuid NOT NULL REFERENCES app_users(id) ON DELETE RESTRICT,
  note text,
  decided_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (approval_request_id, decided_by)
);

CREATE TABLE publication_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content_item_id uuid NOT NULL REFERENCES content_items(id) ON DELETE RESTRICT,
  content_version_id uuid NOT NULL REFERENCES content_versions(id) ON DELETE RESTRICT,
  approval_request_id uuid NOT NULL
    REFERENCES approval_requests(id) ON DELETE RESTRICT,
  job_status text NOT NULL DEFAULT 'queued'
    CHECK (
      job_status IN (
        'queued',
        'running',
        'published',
        'failed',
        'cancelled',
        'rolled_back'
      )
    ),
  idempotency_key text NOT NULL UNIQUE,
  scheduled_for timestamptz,
  published_at timestamptz,
  failure_code text,
  failure_message text,
  retry_count integer NOT NULL DEFAULT 0 CHECK (retry_count >= 0),
  created_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX publication_jobs_queue_idx
  ON publication_jobs(job_status, scheduled_for);

CREATE TABLE index_decisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id uuid REFERENCES regions(id) ON DELETE CASCADE,
  content_item_id uuid REFERENCES content_items(id) ON DELETE CASCADE,
  previous_status text,
  next_status text NOT NULL,
  readiness_assessment_id uuid
    REFERENCES region_readiness_assessments(id) ON DELETE SET NULL,
  approval_request_id uuid
    REFERENCES approval_requests(id) ON DELETE SET NULL,
  reason text NOT NULL,
  decided_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  decided_at timestamptz NOT NULL DEFAULT now(),
  CHECK (
    (region_id IS NOT NULL AND content_item_id IS NULL)
    OR (region_id IS NULL AND content_item_id IS NOT NULL)
  )
);

CREATE INDEX index_decisions_region_idx
  ON index_decisions(region_id, decided_at DESC);
CREATE INDEX index_decisions_content_idx
  ON index_decisions(content_item_id, decided_at DESC);

CREATE TABLE redirects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_path text NOT NULL UNIQUE,
  destination_path text NOT NULL,
  status_code integer NOT NULL CHECK (status_code IN (301, 302, 307, 308)),
  is_active boolean NOT NULL DEFAULT true,
  reason text NOT NULL,
  approved_by uuid REFERENCES app_users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (source_path <> destination_path)
);

-- ---------------------------------------------------------------------------
-- Leads, consent, routing, and integrations
-- ---------------------------------------------------------------------------

CREATE TABLE leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  public_id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  lead_type text NOT NULL
    CHECK (lead_type IN ('family_experience', 'institution_demo', 'partner_cooperation')),
  status text NOT NULL DEFAULT 'new'
    CHECK (
      status IN (
        'new',
        'routed',
        'accepted',
        'contacted',
        'qualified',
        'converted',
        'closed',
        'deleted'
      )
    ),
  contact_name_enc bytea NOT NULL,
  contact_phone_enc bytea NOT NULL,
  contact_phone_hmac text NOT NULL,
  organization_enc bytea,
  message_enc bytea,
  user_region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  intended_region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  source_region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  source_location_id uuid REFERENCES locations(id) ON DELETE SET NULL,
  source_content_item_id uuid REFERENCES content_items(id) ON DELETE SET NULL,
  first_touch jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_touch jsonb NOT NULL DEFAULT '{}'::jsonb,
  anonymous_session_id text,
  route_status text NOT NULL DEFAULT 'pending'
    CHECK (route_status IN ('pending', 'assigned', 'hq_pool', 'failed')),
  assigned_region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  assigned_location_id uuid REFERENCES locations(id) ON DELETE SET NULL,
  retention_until timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX leads_phone_hmac_idx
  ON leads(contact_phone_hmac, created_at DESC);
CREATE INDEX leads_route_idx
  ON leads(route_status, assigned_region_id, assigned_location_id);
CREATE INDEX leads_retention_idx ON leads(retention_until);

CREATE TABLE lead_consents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  consent_type text NOT NULL
    CHECK (consent_type IN ('privacy', 'marketing', 'sensitive_personal_info')),
  policy_version text NOT NULL,
  granted boolean NOT NULL,
  captured_at timestamptz NOT NULL DEFAULT now(),
  capture_context jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX lead_consents_lead_idx ON lead_consents(lead_id);

CREATE TABLE lead_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  assignment_type text NOT NULL
    CHECK (assignment_type IN ('region', 'location', 'user', 'hq_pool')),
  region_id uuid REFERENCES regions(id) ON DELETE SET NULL,
  location_id uuid REFERENCES locations(id) ON DELETE SET NULL,
  user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  routing_rule_version text NOT NULL,
  reason_code text NOT NULL,
  status text NOT NULL DEFAULT 'assigned'
    CHECK (status IN ('assigned', 'accepted', 'rejected', 'reassigned', 'closed')),
  assigned_at timestamptz NOT NULL DEFAULT now(),
  accepted_at timestamptz
);

CREATE INDEX lead_assignments_lead_idx
  ON lead_assignments(lead_id, assigned_at DESC);

CREATE TABLE lead_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  actor_type text NOT NULL
    CHECK (actor_type IN ('user', 'system', 'integration')),
  actor_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  payload_redacted jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX lead_events_lead_idx
  ON lead_events(lead_id, created_at DESC);

CREATE TABLE outbox_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_type text NOT NULL,
  aggregate_id uuid NOT NULL,
  event_type text NOT NULL,
  event_version integer NOT NULL DEFAULT 1,
  payload jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'delivered', 'failed', 'dead_letter')),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  available_at timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz,
  last_error text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX outbox_events_delivery_idx
  ON outbox_events(status, available_at);

CREATE TABLE integration_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  outbox_event_id uuid NOT NULL
    REFERENCES outbox_events(id) ON DELETE CASCADE,
  integration_code text NOT NULL,
  idempotency_key text NOT NULL,
  status text NOT NULL
    CHECK (status IN ('pending', 'success', 'retrying', 'failed', 'dead_letter')),
  external_reference text,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  response_metadata_redacted jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_attempt_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (integration_code, idempotency_key)
);

-- ---------------------------------------------------------------------------
-- Audit
-- ---------------------------------------------------------------------------

CREATE TABLE audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  occurred_at timestamptz NOT NULL DEFAULT now(),
  actor_type text NOT NULL
    CHECK (actor_type IN ('user', 'agent', 'system', 'integration')),
  actor_user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  actor_ai_run_id uuid REFERENCES ai_runs(id) ON DELETE SET NULL,
  action text NOT NULL,
  target_type text NOT NULL,
  target_id uuid,
  request_id text,
  ip_hash text,
  before_state_redacted jsonb,
  after_state_redacted jsonb,
  metadata_redacted jsonb NOT NULL DEFAULT '{}'::jsonb,
  CHECK (
    (actor_type = 'user' AND actor_user_id IS NOT NULL)
    OR (actor_type = 'agent' AND actor_ai_run_id IS NOT NULL)
    OR (actor_type IN ('system', 'integration'))
  )
);

CREATE INDEX audit_log_target_idx
  ON audit_log(target_type, target_id, occurred_at DESC);
CREATE INDEX audit_log_actor_idx
  ON audit_log(actor_type, actor_user_id, occurred_at DESC);

-- ---------------------------------------------------------------------------
-- Updated-at triggers
-- ---------------------------------------------------------------------------

CREATE TRIGGER app_users_set_updated_at
BEFORE UPDATE ON app_users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER regions_set_updated_at
BEFORE UPDATE ON regions
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER locations_set_updated_at
BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER media_assets_set_updated_at
BEFORE UPDATE ON media_assets
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER claims_set_updated_at
BEFORE UPDATE ON claims
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER content_items_set_updated_at
BEFORE UPDATE ON content_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER publication_jobs_set_updated_at
BEFORE UPDATE ON publication_jobs
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER redirects_set_updated_at
BEFORE UPDATE ON redirects
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER leads_set_updated_at
BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER integration_deliveries_set_updated_at
BEFORE UPDATE ON integration_deliveries
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;

-- 正式实现前必须补充：
-- 1. Row Level Security 或等价服务层授权；
-- 2. content_items.current_version_id/published_version_id 必须属于同一 content_item；
-- 3. 状态机转换函数与测试；
-- 4. PII 加密/HMAC 密钥管理与轮换；
-- 5. 审计日志防篡改和保留策略；
-- 6. JSON Schema 校验方式；
-- 7. 数据保留、删除和匿名化任务；
-- 8. 生产 migration 的回滚与兼容策略。

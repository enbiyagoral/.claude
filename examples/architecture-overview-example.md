# Architecture overview

<!-- This is a FILLED-IN example showing the depth expected from the onboard skill's
     Phase 3g. Copy to docs/architecture/OVERVIEW.md and replace with your project's
     actual architecture. The key is specificity — file paths, config values, service
     names. Not "uses JWT" but "JWT issued by X, validated by Y, stored in Z." -->

## System overview

Acme Commerce is a monorepo with 3 TypeScript services behind an nginx API gateway. The web frontend is a Next.js app served from Vercel. The API and worker run on Kubernetes (EKS) managed by ArgoCD. All services share a PostgreSQL database but have separate schemas.

## Service map

- **api** (`packages/api/`) — Express + Prisma. Handles all REST endpoints. Entry point: `src/index.ts` → routes registered in `src/routes/index.ts`. Runs as a Kubernetes Deployment with 2-4 replicas behind an nginx ingress.
- **web** (`packages/web/`) — Next.js 14 with App Router. Deployed to Vercel via GitHub integration (push to main → auto-deploy). Uses `packages/shared/` for types and validation schemas.
- **worker** (`packages/worker/`) — BullMQ consumer processing background jobs (email, PDF generation, data sync). Reads from Redis queue `acme:jobs`. Entry point: `src/worker.ts` with job handlers in `src/jobs/`.
- **shared** (`packages/shared/`) — Zod schemas, TypeScript types, and utility functions. Published as internal package, consumed by api and web.

## Authentication and authorization

JWT-based with refresh token rotation.

- **Token issuance:** `POST /api/auth/login` in `packages/api/src/routes/auth.ts:login()`. Validates credentials against `users` table (bcrypt hashed passwords). Returns `accessToken` (15min, signed with `JWT_SECRET`) and `refreshToken` (7d, stored in `auth_refresh_tokens` table with device fingerprint).
- **Token validation:** Express middleware in `packages/api/src/middleware/auth.ts:requireAuth()`. Decodes JWT, attaches `req.user` with `{ id, email, role }`. Returns 401 on expiry, 403 on insufficient role.
- **Refresh flow:** `POST /api/auth/refresh` rotates the refresh token — old token is invalidated, new pair issued. Refresh tokens are single-use.
- **Roles:** Three roles defined in `packages/shared/src/types/auth.ts`: `admin`, `manager`, `member`. Checked via `requireRole('admin')` middleware. Role hierarchy is not implicit — each role's permissions are explicitly listed in `packages/api/src/config/permissions.ts`.
- **Third-party auth:** Google OAuth via Passport.js (`packages/api/src/strategies/google.ts`). Creates local user on first login, links to existing user by email thereafter.

## Deployment pipeline

```text
Developer pushes to feature branch
  → GitHub Actions: lint + test + type-check (`.github/workflows/ci.yml`)
  → PR review required (CODEOWNERS: @acme/platform for packages/api/*, @acme/frontend for packages/web/*)

Merge to main
  → GitHub Actions: build Docker images, push to ECR (`packages/api/Dockerfile`, `packages/worker/Dockerfile`)
  → ArgoCD detects new image tag in `deploy/k8s/overlays/staging/kustomization.yaml`
  → Auto-deploys to staging cluster

Release (git tag v*)
  → GitHub Actions: promote staging image to production tag
  → ArgoCD syncs `deploy/k8s/overlays/production/kustomization.yaml`
  → Manual sync required (ArgoCD auto-sync disabled for production)
  → Slack notification to #deployments channel

Vercel (web only)
  → Push to main → auto-deploy to preview
  → Production deploy triggered by Vercel GitHub integration on main branch
```

- **Rollback:** ArgoCD history-based. `argocd app rollback acme-api` restores previous manifest. Database migrations are forward-only — rollback requires a new migration.
- **Feature flags:** LaunchDarkly SDK in both api (`packages/api/src/lib/flags.ts`) and web (`packages/web/src/lib/flags.ts`). Flags are evaluated server-side in API, client-side hydrated via `getServerSideProps` in web.

## Data layer

**PostgreSQL 15** on RDS (`us-east-1`), three schemas:

- `public` — core domain: `users`, `organizations`, `products`, `orders`. Managed by Prisma (`packages/api/prisma/schema.prisma`). Migrations in `packages/api/prisma/migrations/`.
- `analytics` — read-only views and materialized views for dashboard queries. Refreshed by worker job `RefreshAnalytics` (runs every 15min).
- `audit` — append-only audit log. Written by database triggers, never by application code.

**Redis 7** on ElastiCache:

- `acme:sessions:*` — rate limiting counters (sliding window, `packages/api/src/middleware/rateLimit.ts`)
- `acme:jobs` — BullMQ job queue for worker
- `acme:cache:*` — query cache with 5min TTL (product listings, organization settings)

**No message queue beyond BullMQ.** Inter-service communication is synchronous (API calls between api and worker are avoided — worker reads directly from the database and Redis queue).

## Network topology

```text
Internet
  │
  ├── Vercel CDN → web (Next.js)
  │
  └── AWS ALB → nginx ingress (EKS)
        ├── /api/* → api service (ClusterIP)
        └── /ws/*  → api service (WebSocket upgrade)

Internal (VPC):
  ├── api → PostgreSQL (RDS, private subnet, port 5432)
  ├── api → Redis (ElastiCache, private subnet, port 6379)
  ├── worker → PostgreSQL (same RDS instance)
  └── worker → Redis (same ElastiCache cluster)
```

- **No VPN required** for development — local environment uses Docker Compose with local Postgres and Redis.
- **Bastion host** available at `bastion.acme.internal` for production database access (SSH tunnel, requires team VPN).
- **Network policies:** worker pods cannot receive ingress traffic (only make outbound connections to RDS and Redis).

## Secrets and configuration

- **Production/Staging:** AWS Secrets Manager, synced to Kubernetes via External Secrets Operator (`deploy/k8s/base/external-secrets/`). Secrets are mounted as environment variables, never as files.
- **Local development:** `.env` file copied from `.env.example`. Contains local Postgres/Redis URLs and a development `JWT_SECRET`. Real third-party keys (Google OAuth, LaunchDarkly, Stripe) have separate dev-environment credentials documented in the team wiki.
- **Environment-specific config:** Kustomize overlays in `deploy/k8s/overlays/{staging,production}/`. Differences: replica count, resource limits, external URLs, feature flag defaults.
- **Sensitive values in code:** None. All secrets are injected via environment. Grep for `process.env` to see what each service expects — the complete list is in `packages/api/.env.example` and `packages/worker/.env.example`.

## Observability

- **Logging:** Pino structured JSON logs (`packages/api/src/lib/logger.ts`). Shipped to Datadog via Kubernetes log collection. Correlation ID attached in `packages/api/src/middleware/requestId.ts` and propagated through all log calls.
- **Metrics:** Prometheus metrics exposed at `/metrics` on each service. Scraped by kube-prometheus-stack. Key dashboards in Grafana: "API Latency" (p50/p95/p99 by endpoint), "Worker Queue Depth", "Database Connections".
- **Alerting:** PagerDuty integration. Alerts defined in `deploy/k8s/base/prometheus-rules/`. Critical alerts: API error rate > 5% for 5min, worker queue depth > 1000, database connection pool exhaustion.
- **No distributed tracing** yet — tracked in Linear as ACME-892.

## Blast radius and dependencies

| If you change...            | What could break                           | Coordinated deploy needed?              |
| --------------------------- | ------------------------------------------ | --------------------------------------- |
| `packages/shared/` types    | api + web + worker (all import shared)     | Yes — all three must be compatible      |
| Prisma schema               | api + worker (both use the database)       | Yes — migrate before deploying new code |
| `packages/api/src/routes/`  | web (calls API endpoints)                  | Only if request/response shape changes  |
| `packages/worker/src/jobs/` | Nothing else (worker is isolated consumer) | No                                      |
| Redis key format            | api + worker (shared Redis)                | Yes — coordinate cache key changes      |
| Kubernetes manifests        | Only the affected service                  | No (ArgoCD deploys independently)       |

**Single points of failure:** PostgreSQL (one RDS instance, no read replicas yet — tracked as ACME-756). Redis is used for both caching and job queue — if Redis goes down, both API performance and background processing are affected.

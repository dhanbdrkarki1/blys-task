# REASONING

## Architecture Context

This PoC uses a production-style baseline on AWS with Terraform-managed infrastructure:

- VPC with public and private subnets across multiple Availability Zones.
- Internet-facing ALB in public subnets.
- ECS on Fargate for application workloads in private subnets.
- Secrets delivered from SSM Parameter Store and Secrets Manager.
- CI/CD pipeline that builds container images, pushes to ECR, and deploys to ECS.
- ECS rolling deployment with deployment circuit breaker and automatic rollback to reduce release risk and customer-visible impact.

This gives a good startup balance: managed services reduce ops overhead while still supporting high availability and secure network boundaries.

## Cost Optimization

### NAT Gateway Strategy

For the current application, a NAT Gateway is not strictly required for normal runtime traffic. The main outbound dependency is pulling container images from ECR.

In this setup, NAT Gateways were still created in two separate AZs to satisfy the challenge requirement and to keep a production-like high-availability network pattern.

For the actual workload needs, a more cost-efficient design is to use VPC Endpoints for ECR (and related endpoints) so private workloads can pull images without internet/NAT traversal. This is typically cheaper, reduces external exposure, and remains reliable for private subnet operations.

Recommended endpoints for this pattern:

- `com.amazonaws.<region>.ecr.api`
- `com.amazonaws.<region>.ecr.dkr`
- `com.amazonaws.<region>.s3` (gateway endpoint for ECR image layers)
- `com.amazonaws.<region>.logs` (for CloudWatch Logs ingestion without NAT)

For lower environments, cost can be reduced by:

- using a single NAT Gateway,
- replacing NAT-dependent image pulls with ECR VPC Endpoints where applicable,
- reducing ECS desired count and autoscaling max,
- minimizing always-on workloads and retaining only required logs.

### Compute and Scaling

ECS Fargate avoids EC2 instance management and over-provisioning. Target tracking autoscaling allows the service to scale out only when needed and scale in during low traffic, lowering idle spend.

### Operational Cost Controls

Recommended controls:

- Use AWS Budgets with alerts for monthly thresholds.
- Right-size task CPU/memory after observing real utilization.
- Apply log retention windows (avoid unlimited retention).
- Keep non-production resources on reduced footprint profiles.

### Cost Estimate Reference

- AWS Pricing Calculator estimate for this PoC:
  [https://calculator.aws/#/estimate?id=3d8c8d73146b9e604db13c76f7474abb68571adb](https://calculator.aws/#/estimate?id=3d8c8d73146b9e604db13c76f7474abb68571adb)

- The estimate should be reviewed periodically as traffic, retention windows, and observability integrations evolve.

## Disaster Recovery (Region-Level Outage)

If an AWS region goes offline, recovery is handled through IaC re-provisioning in a secondary region.

### Recovery Approach

1. Prepare region-specific Terraform inputs (VPC CIDRs, AZs, certificate, DNS targets).
2. Initialize and apply Terraform in the secondary region.
3. Deploy container image to ECR in the failover region (or replicate images).
4. Start ECS service and verify ALB health checks.
5. Update DNS (Route 53 failover/weighted records) to point traffic to secondary-region ALB.

### Prerequisites for Fast Recovery

- Remote state strategy and backend access are region-safe and documented.
- Secrets are available in the failover region (replicated or re-seeded securely).
- Certificates are provisioned in the failover region in advance when possible.
- CI/CD supports region override for emergency deployment.

### Recovery Objectives

- **RTO (Recovery Time Objective):** approximately 15-30 minutes, assuming Terraform apply, ECS deployment, health verification, and DNS propagation complete normally.
- **RPO (Recovery Point Objective):** near-zero for this stateless service, since application artifacts are stored in ECR and infrastructure is reproducible from code.

This approach keeps DR operationally simple: rebuild the same architecture from code and shift traffic with DNS.

## Observability Strategy

### Baseline (Pragmatic Default)

- CloudWatch Logs for container logs.
- CloudWatch Metrics/Alarms for ECS service health, task restart patterns, CPU/memory, and ALB target health.
- Basic alert routing via SNS/ChatOps (Slack/email).

### Suggested Alarm Set

- ALB 5xx spike and unhealthy target count.
- ECS service running task count below desired count.
- Sustained high CPU/memory.
- Deployment failure or frequent task restarts.

### Future Enhancements

As traffic grows, add:

- Prometheus + Grafana for richer service-level metrics and SLO dashboards.
- Centralized log analytics (ELK/OpenSearch) if cross-service query depth is needed.
- A dedicated observability sidecar container per task (or shared agent pattern) for telemetry collection and forwarding.
- APM and distributed tracing (OpenTelemetry with X-Ray, Datadog APM, or similar) for request-level visibility across services.
- ECS service health dashboards (latency, error rate, running task count, deployment state, restart count) for fast triage.
- ALB-focused monitoring (request count, target response time, HTTPCode_ELB_5XX/4XX, HTTPCode_Target_5XX, healthy host count, rejected connections) to quickly isolate edge vs service failures.
- ECS cluster monitoring set to `enhanced` when deeper task/container-level metrics are required beyond service-level aggregation.
- Fluent Bit (preferred lightweight option) or Fluentd for log forwarding to Grafana, OpenSearch, Datadog, or other observability backends.
- If external platforms are not preferred, create custom CloudWatch Dashboards in AWS combining ALB, ECS service, task, and log-based alarm widgets as an AWS-native observability layer.

Network implication for this stage:

- With basic CloudWatch-only observability, NAT dependency can remain minimal (or avoided with VPC Endpoints for AWS services).
- Once sidecars/agents export telemetry to external SaaS endpoints, NAT Gateway or equivalent egress path is typically required.
- For cost/security optimization, keep AWS-native telemetry on PrivateLink/VPC Endpoints where possible, and use NAT only for non-private external observability destinations.

This layered model keeps initial cost low while allowing observability maturity over time.

## CI/CD Strategy Rationale

The pipeline follows a build -> push -> deploy flow to keep release stages deterministic and auditable.
Build produces a consistent artifact from source, push stores that exact version in ECR, and deploy promotes the same artifact to ECS without rebuilding in later stages.

Immutable image tags improve rollback safety and reduce "works on my machine" drift, because each deployment references a fixed container digest/tag.

Automated deployment is preferred over manual release steps to reduce human error, improve repeatability, and shorten recovery time during incidents.

Testing and security scanning should run before deployment as quality gates (for example linting, unit/integration tests, dependency checks, container scanning, and IaC scanning), so only validated artifacts are promoted to production.

## Why This Fits Blys Requirements

- **Cost-aware:** Uses managed services and autoscaling; supports lower-cost profiles for non-prod.
- **Reliable:** Multi-AZ networking and ALB + ECS patterns align with production-ready availability goals.
- **Low-impact releases:** ECS rolling deployments plus circuit-breaker rollback reduce downtime risk and limit customer impact during releases.
- **Secure by design:** Private compute, scoped IAM roles, and externalized secrets.
- **Operable at 3 AM:** Infra is reproducible from Terraform, and failure recovery is process-driven rather than ad hoc.

### Example Failure Scenarios (3 AM Reality Check)

- ECS task crash: ECS service scheduler replaces unhealthy/stopped tasks automatically, while CloudWatch alarms notify the on-call engineer.
- ALB unhealthy targets: target-group health degradation triggers alerts, and responders can roll back to the last known-good ECS task definition/image.
- Deployment failure: ECS deployment circuit breaker detects failing rollout and automatically stops/rolls back the deployment to maintain service availability.

## AWS Security Posture and IAM Justification

Security groups are tightly scoped for application traffic flow:

- ALB accepts internet traffic on 80/443 and forwards only to ECS app port.
- ECS tasks accept app traffic only from the ALB security group.
- Workloads run in private subnets with no public IP assignment.

IAM is mostly resource-scoped (ECR repository ARN, specific SSM parameters, specific Secrets Manager ARNs, scoped ECS service/task resources for CI/CD).

Additional security design choices:

- ECS tasks run without public IPs to reduce direct internet exposure and enforce controlled ingress through ALB only.
- Task roles are used for workload access to AWS services, which is safer and more granular than broad instance-profile style permissions.
- Optional hardening: attach AWS WAF to the ALB for managed protections (for example common web exploits, bot/rate controls, and IP reputation filtering).

## Architecture References

- Primary infrastructure diagram: `docs/images/blys-architecture-infra.png`
- Additional supporting screenshots/diagrams realted to workflow: `docs/images/`

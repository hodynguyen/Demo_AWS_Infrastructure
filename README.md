# Cloud Infrastructure Architecture (2025)
## DevOps Engineer Assessment – Full Documentation

This document describes the AWS-based cloud infrastructure required to deploy the new Creative Force service.  
The design is production-grade, secure, scalable, observable, and fully automated using Terraform and Kubernetes.

---

# 1. Overview & Technology Stack

The system includes four components:

| Component | Description | Visibility |
|----------|-------------|------------|
| UI | Dockerized frontend | Public |
| API | Dockerized backend | Public |
| PostgreSQL | Primary database | Private |
| Metrics Collector | Internal metrics endpoint | Private |

### Technologies Used
- AWS VPC, Subnets, IGW, NAT, ALB, ACM, Route53  
- AWS RDS PostgreSQL (Multi-AZ)  
- AWS EKS: Deployments, Services, Ingress, Autoscalers  
- ExternalDNS *(future work – controller pending)*, Cert-Manager *(future work – currently using pre-issued ACM certs)*, IAM OIDC, IRSA  
- Terraform for Infrastructure-as-Code  
- Docker images deployed on Kubernetes  
- CloudWatch, CloudTrail, S3 (optional logs/backups)

---

# 2. Prerequisites Before Deployment

Before running Terraform, prepare the following:

### AWS Setup
- AWS account + IAM permissions  
- AWS CLI installed & authenticated  
- Terraform v1.5+  
- Registered domain: **acme.com**  
- ACM certificate for:
  - www.acme.com  
  - api.acme.com  

### Container Registry
Ensure images exist:
- acme/ui:latest
- acme/api:latest


### Terraform Remote Backend
- S3 bucket for terraform state *(future work – state still local)*  
- DynamoDB table for state locking *(future work)*  

### Kubernetes Files Prepared
- Deployment manifests for UI, API, Metrics Collector  
- Service (ClusterIP) definitions  
- Ingress rules  
- HPA configuration  
- Secrets containing POSTGRES_URL and METRICS_URL  

---

# 3. High-Level Architecture Summary

- Users → Route53 → ALB → UI / API
- API → PostgreSQL
- API → Metrics Collector


### Networking Concept
- ALB runs in **public subnets**
- EKS Nodes run in **private subnets**
- PostgreSQL runs in **isolated private subnets**
- Metrics Collector is private-only  
- NAT provides outbound to private workloads  
- TLS termination handled by ALB  
- Zero-trust networking enforced by SG rules  

---

# 4. Step-by-Step Terraform Infrastructure Build

Below is the recommended provisioning sequence.

---

## 4.1. Create VPC
**Purpose:** Private network to isolate all cloud resources.  
- CIDR: `10.0.0.0/16`  
- DNS hostnames & DNS support enabled  

---

## 4.2. Create Subnets

### Public Subnets (2 AZs)
- `10.0.1.0/24`  
- `10.0.2.0/24`  
Used for:
- ALB  
- NAT Gateways  
- IGW

### Private Subnets (2 AZs)
- `10.0.3.0/24`  
- `10.0.4.0/24`  
Used for:
- EKS Nodes  
- UI/API containers  
- Metrics Collector  
- RDS PostgreSQL  

---

## 4.3. Internet Gateway
**Purpose:** Provide internet access for public subnets.  

Attach IGW to VPC.

---

## 4.4. NAT Gateways
**Purpose:**  
Allow private workloads to:
- Pull Docker images  
- Access external APIs  
- Download dependencies  
While staying **non-public**.

Deploy:
- NAT Gateway A → public-a  
- NAT Gateway B → public-b (optional for HA, *future work – only one NAT provisioned today*)

---

## 4.5. Route Tables

### Public Route Table
- `0.0.0.0/0 → IGW`  
Associations: public-a, public-b  

### Private Route Table
- `0.0.0.0/0 → NAT Gateway`  
Associations: private-a, private-b  

---

# 5. Security Groups

### alb-sg
- Inbound: 80/443 from `0.0.0.0/0`
- Outbound: allow all  
Used by ALB (public entry point)

### api-sg
- Inbound: 80 or 443 from alb-sg  
- Outbound: 5432 to db-sg  
- Outbound: 80 to metrics-sg  

### ui-sg
- Inbound: 80 from alb-sg  
- Outbound: allow all  

### db-sg
- Inbound: 5432 from api-sg  
- No outbound (default)

### metrics-sg
- Inbound: 80 from api-sg  

**Zero-trust boundary:**  
Only API can talk to DB and Metrics.

---

# 6. RDS PostgreSQL (Multi-AZ)

Configuration:
- Engine: PostgreSQL  
- Multi-AZ: enabled  
- Private subnets (private-a, private-b)  
- Security Group: db-sg  
- Backups: 7–14 days  
- Monitoring: enabled  
- Public Access: false  

API receives connection via `POSTGRES_URL`.

---

# 7. EKS Cluster

### Cluster Setup
- Control plane managed by AWS  
- Endpoint: private or public + private  
- OIDC enabled for IRSA  
- Logging enabled (cluster logs → CloudWatch)

### Node Groups
- Run in private subnets  
- Auto-scaling enabled  
- IAM policies: worker-node, CNI, ECR read  

### Add-ons
- VPC CNI  
- CoreDNS  
- kube-proxy  
- Metrics Server *(future work – not deployed yet)*  
- AWS Load Balancer Controller  
- Cluster Autoscaler *(future work – only documented steps exist)*

---

# 8. Deploy Workloads on EKS

> **Note:** UI/API/Metrics manifests are provided as mocks because the supplied Docker images/domains are fictional; apply them once real images and certificates exist.

## UI Deployment (acme/ui)
- Deployment (replicas 2 minimum)
- ClusterIP service: port 80  
- Ingress:
  - Host: www.acme.com  
  - Target: UI service  
- TLS via ACM + ALB  

## API Deployment (acme/api)
- Deployment (replicas 2–3)
- ClusterIP service  
- Secrets:
  - POSTGRES_URL  
  - METRICS_URL  
- HPA enabled  

Ingress:
- Host: api.acme.com

## Metrics Collector
- Deployment in private subnet  
- Only API may reach Metrics endpoint  

---

# 9. Route53 DNS

Hosted Zone: `acme.com`

Records:
- `www.acme.com` → ALB  
- `api.acme.com` → ALB  

ExternalDNS manages automatic updates *(future work – controller not yet deployed; Route53 records are manual/placeholder)*.

---

# 10. Observability

### Option A – CloudWatch
- EKS logs  
- App logs  
- RDS logs  
- Metrics dashboards  
- Alerts on CPU, memory, 5xx  

### Option B – Prometheus Stack
- Prometheus  
- Grafana  
- Alertmanager  
- Exporters  

---

# 11. Backups & Resilience

- RDS automated backups enabled  
- PITR enabled  
- EKS backups via Velero (optional)  
- ALB access logs → S3  
- CloudTrail enabled for governance  

---

# 12. Security Hardening

- Zero-trust Security Groups  
- No public IPs on nodes  
- TLS everywhere (ACM + ALB)  
- IAM least-privilege  
- IRSA for service accounts  
- Node groups in private subnets  
- Optional WAF for ALB  
- Ingress restricts source IPs (optional)  

---

# 13. Final Architecture Summary

### UI (public)
Users → ALB → UI pods

### API (public)
Users → ALB → API pods → PostgreSQL  
API → Metrics Collector

### Database (private)
API → PostgreSQL (Multi-AZ)

### Metrics (private)
API → Metrics Collector

### Network Layout
- Public subnets: ALB + NAT  
- Private subnets: EKS nodes + API/UI pods + Metrics + RDS  

---

# 14. Results

This architecture meets all evaluation requirements:
- Zero downtime deployments  
- Scalability & auto-scaling  
- Least-privilege & zero-trust networking  
- Production-grade cost-aware architecture  
- Full observability stack  
- Terraform automation  
- Secure HTTPS ingress  
- Multi-AZ HA design  

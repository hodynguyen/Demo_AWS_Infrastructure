# Assessment_AWS_Infrastructure Template

## 1. Problem Definition

You are tasked with designing the **cloud infrastructure** for a new service.  
The application is composed of several components, each packaged in a Docker image.

---

## UI  
- Static web front-end  
- **Image:** `acme/ui`  
- **Domain:** `www.acme.com`  
- **Ports:** 80 / 443  
- **Public:** Yes  

---

## API  
- Stateless REST API  
- **Image:** `acme/api`  
- **Domain:** `api.acme.com`  
- **Port:** 443  
- **Public:** Yes  

### Environment Variables  
- `POSTGRES_URL`  
- `METRICS_URL`  

---

## Database — PostgreSQL  
- **Port:** 5432  
- **Public:** No (must be private/subnet-isolated)

---

## Metrics Collector  
(e.g., Prometheus agent, APM agent, OTEL collector)  
- **Port:** 80  
- **Public:** No  

---

# 2. Evaluation Criteria  

Your architecture and solution should follow **best practices** across the following areas:

### ✔ Deployment Automation & Zero-Downtime Updates  
Blue/Green deployments, rolling updates, CI/CD integration.

### ✔ Scalability & Auto-Scaling  
Horizontal & vertical scaling, cluster autoscaler, HPA/VPA.

### ✔ Security & Zero-Trust Networking  
Private subnets, SG chaining, least privilege IAM, IRSA, OIDC.

### ✔ HTTPS Termination & Ingress  
TLS certificates, ALB/NLB, secure ingress policies.

### ✔ Infrastructure-as-Code (IaC)  
Terraform / Pulumi / CDK / Helm / Kustomize.

### ✔ Backups, Disaster Recovery & Resilience  
RDS backups, point-in-time restore, multi-AZ setup, cluster recovery.

### ✔ Observability & Metrics  
Logging, tracing, monitoring, alerting, dashboards.

### ✔ Cost Awareness  
Resource sizing, autoscaling thresholds, NAT cost optimization, storage type.

### ✔ Risk Analysis & Collaboration  
Identify:  
- Potential shortcomings  
- Technical debt  
- Design trade-offs  
- Collaboration requirements with engineering teams  
- Recommendations for future improvements  

---

This document defines the scope and requirements for designing a production-grade, secure, and scalable cloud infrastructure for the provided application components.


# Journal API — Cloud-Native DevOps Project

## Project Overview

Journal API is an end-to-end cloud and DevOps engineering project demonstrating the evolution of a Python FastAPI application from local application development through traditional cloud deployment and ultimately into a containerized, Kubernetes-based platform on AWS.

The project covers the full application and infrastructure lifecycle, including application development, automated testing, containerization, Infrastructure as Code, CI/CD, Kubernetes orchestration, managed databases, networking, and observability.

The final architecture uses Docker, Amazon ECR, Amazon EKS, Amazon RDS, Terraform, GitHub Actions, and the LGTM observability stack with OpenTelemetry.


---

# Architecture

<br>

<p align="center">
  <img src="docs/Architecture.png" alt="AWS Two-Tier Architecture" width="1000">
</p>

<br>

The production architecture runs the Journal API as a containerized workload on Amazon EKS.

The EKS environment spans multiple Availability Zones and uses private subnets for application workloads and database resources.

### Why EKS?

Amazon EKS is intentionally more infrastructure than this application's current workload requires.

A small CRUD API like Journal API could be deployed more simply and cost-effectively using a service such as Amazon ECS with Fargate or AWS App Runner. EKS was chosen because one of the primary goals of this project was to gain hands-on experience building and operating a Kubernetes-based platform on AWS.

Using EKS provided practical experience with Kubernetes deployments, services, health probes, rolling deployments, container scheduling, networking, CI/CD integration, and Kubernetes-native observability.

The architecture therefore represents a **learning and platform-engineering environment rather than the minimum infrastructure required to run the application**.

For a low-traffic production workload where cost and operational simplicity were the primary requirements, I would evaluate a simpler managed compute platform before choosing Kubernetes.

---

# DevOps Workflow

The application follows an automated CI/CD workflow using GitHub Actions.

When application changes are pushed through the development workflow, GitHub Actions performs the following stages:

1. Runs automated tests and code-quality checks.
2. Builds the Journal API Docker image.
3. Authenticates to AWS using GitHub Actions OIDC.
4. Pushes the container image to Amazon ECR.
5. Connects to the Amazon EKS cluster.
6. Updates the Kubernetes deployment.
7. Kubernetes performs a rolling deployment of the new application version.

This creates an automated path from source code to the Kubernetes environment.

```text
Code Change
     |
     v
   GitHub
     |
     v
GitHub Actions
     |
     +--> Test
     |
     +--> Docker Build
     |
     +--> Amazon ECR
     |
     +--> Amazon EKS
              |
              v
       Kubernetes Deployment
              |
              v
        Journal API Pods
```

---

# Kubernetes Deployment

The Journal API is deployed to Amazon Elastic Kubernetes Service (EKS).

The application is packaged as a Docker image and stored in Amazon Elastic Container Registry (ECR). Kubernetes worker nodes pull the image from ECR and run the application inside Kubernetes pods.

The Kubernetes deployment includes:

* Application Deployment
* Multiple application pods
* Kubernetes Service
* AWS Load Balancer integration
* Liveness probes
* Readiness probes
* Environment configuration
* Rolling deployments

The application exposes:

```text
/health
/metrics
```

The `/health` endpoint is used by Kubernetes health probes, while `/metrics` exposes application metrics for Prometheus.

---

# CI/CD Pipeline

GitHub Actions provides the project's continuous integration and continuous deployment pipeline.

### Continuous Integration

The CI stage validates application changes using:

* pytest
* Ruff
* Pyright
* PostgreSQL test database

### Container Build

After validation, GitHub Actions:

```text
Dockerfile
    |
    v
Docker Build
    |
    v
Docker Image
    |
    v
Amazon ECR
```

### Continuous Deployment

After the image is pushed to ECR, the deployment stage authenticates with AWS, connects to Amazon EKS, and applies the Kubernetes manifests.

Kubernetes then performs the application rollout across the EKS worker nodes.

AWS authentication from GitHub Actions uses **OpenID Connect (OIDC)** rather than long-lived AWS access keys.

---

# Observability

The project includes a Kubernetes-native observability stack for monitoring application and cluster health.

## Prometheus

Prometheus collects application and Kubernetes metrics.

The Journal API exposes Prometheus-compatible metrics through:

```text
/metrics
```

Metrics include application request activity and infrastructure telemetry.

---

## Grafana

<br>

<p align="center">
  <img src="docs/grafana - Kubernetes API server.png" alt="Grafana Kubernetes API Server" width="49%">
  <img src="docs/grafana - Journal API.png" alt="Journal API" width="49%">
</p>

<br>

Grafana provides dashboards for visualizing application and Kubernetes performance.

Dashboards monitor areas such as:

* HTTP request volume
* Application error rate
* Request latency
* Kubernetes CPU usage
* Kubernetes memory usage
* Application exceptions

Grafana alerting is also configured to detect application issues such as elevated error rates or latency.

---

## Loki

Loki provides centralized log aggregation for the Kubernetes environment.

Application logs can be queried and analyzed through Grafana, allowing application failures to be correlated with metrics and traces.

---

## Tempo

Tempo provides distributed tracing.

Application requests are instrumented using OpenTelemetry and traces can be inspected through Grafana to understand request execution across application components.

---

## OpenTelemetry

The OpenTelemetry Collector provides the telemetry pipeline between the application and observability services.

```text
Journal API
    |
    v
OpenTelemetry
    |
    +------> Prometheus
    |
    +------> Loki
    |
    +------> Tempo
                 |
                 v
               Grafana
```

Together, these tools provide visibility across the three major observability signals:

```text
Metrics  -> Prometheus
Logs     -> Loki
Traces   -> Tempo
             |
             v
           Grafana
```

---

# AWS Infrastructure

The project uses several AWS services to provide compute, networking, container hosting, database services, security, and traffic management.

| AWS Service            | Purpose                             |
| ---------------------- | ----------------------------------- |
| Amazon EKS             | Managed Kubernetes cluster          |
| Amazon ECR             | Docker container image registry     |
| Amazon RDS             | Managed PostgreSQL database         |
| Amazon EC2             | EKS worker node compute             |
| Amazon VPC             | Network isolation                   |
| Elastic Load Balancing | External application traffic        |
| Route 53               | DNS                                 |
| AWS Certificate Manager| TLS certificates                    |
| S3                     | Terraform remote state              |
| IAM                    | AWS permissions and workload access |
| Security Groups        | Network access control              |


The environment uses multiple Availability Zones with public and private networking to provide workload isolation and improved availability.

---

## Technology Stack

| Category | Technology |
| --- | --- |
| Backend | FastAPI |
| Application Server | Uvicorn |
| Language | Python 3.12 |
| Database | PostgreSQL / Amazon RDS |
| Package Management | uv |
| Cloud Platform | AWS |
| Containers | Docker |
| Container Registry | Amazon ECR |
| Orchestration | Kubernetes |
| Managed Kubernetes | Amazon EKS |
| Kubernetes Packaging | Helm |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| DNS | Amazon Route 53 |
| TLS | AWS Certificate Manager |
| Load Balancing | AWS Elastic Load Balancing |
| Persistent Storage | Amazon EBS / EBS CSI Driver |
| Metrics | Prometheus |
| Visualization | Grafana |
| Logging | Loki |
| Tracing | Tempo |
| Telemetry | OpenTelemetry |
| Version Control | Git & GitHub |


---

# Infrastructure as Code

AWS infrastructure is managed with Terraform.

The Terraform configuration is separated into reusable modules:

```text
infra/
├── backend.tf
├── providers.tf
├── variables.tf
├── output.tf
├── main.tf
└── modules/
    ├── network/
    ├── eks/
    ├── database/
    └── observability/
```

This makes the infrastructure repeatable, reviewable, and easier to reproduce.

## Terraform State Management

Terraform state is stored remotely in Amazon S3 rather than being maintained locally.

The backend infrastructure is separated from the main application infrastructure because the S3 state bucket must exist before Terraform can initialize and use it as a remote backend.

A dedicated `bootstrap/` Terraform configuration provisions the state bucket with:

* S3 versioning for state recovery
* Server-side encryption
* Public access blocking

The main Terraform configuration in `infra/` uses this bucket through an S3 backend defined in `backend.tf`.

S3-native state locking is enabled to prevent concurrent Terraform operations from modifying the state at the same time.

Separating the backend infrastructure from the application infrastructure provides a reliable foundation for managing Terraform state while keeping the main AWS infrastructure reproducible and version controlled.

---

# Application Features

The Journal API provides REST API functionality for creating and managing journal entries.

Application functionality includes:

* Create journal entries
* Retrieve journal entries
* Retrieve individual entries
* Update journal entries
* Delete journal entries
* Input validation
* AI-assisted journal analysis
* Application logging
* Health monitoring
* Prometheus metrics
* OpenTelemetry instrumentation

---

# Repository Structure

```text
journal-starter/
│
├── .github/
│   └── workflows/              # GitHub Actions workflows
│
├── api/                        # FastAPI application
│
├── bootstrap/                  # Terraform remote-state bootstrap
│
├── infra/                      # AWS Terraform configuration
│   └── modules/
│       ├── network/
│       ├── eks/
│       ├── database/
│       └── observability/
│
├── k8s/                        # Kubernetes manifests
│   ├── aws/                    # AWS/Kubernetes integration
│   └── observability/          # Observability configuration
│
├── tests/                      # Automated tests
│
├── scripts/                    # Deployment/support scripts
│
├── Dockerfile                  # Production container image
├── database_setup.sql          # PostgreSQL initialization
├── pyproject.toml              # Python project configuration
├── uv.lock                     # Locked Python dependencies
└── README.md
```

---

# Original EC2 Deployment

Before migrating the application to Kubernetes, the Journal API was deployed using a traditional AWS two-tier architecture.

The original environment consisted of:

```text
Internet
   |
   v
Public EC2
FastAPI + Uvicorn + Nginx
   |
   v
Private EC2
PostgreSQL
```

This initial deployment established the networking and infrastructure foundation before the application was containerized and migrated to Amazon EKS.

---

# Key DevOps Concepts Demonstrated

This project demonstrates hands-on implementation of:

**Cloud Infrastructure**

* AWS networking and VPC design
* Public/private subnet architecture
* Security groups
* IAM
* Managed AWS services

**Containers & Kubernetes**

* Docker image creation
* Container registries
* Kubernetes Deployments and Services
* Pod scheduling
* Health checks
* Rolling deployments
* Amazon EKS

**CI/CD**

* Automated testing
* Docker image builds
* Amazon ECR publishing
* Automated Kubernetes deployments
* GitHub Actions
* AWS OIDC authentication

**Infrastructure as Code**

* Terraform
* Repeatable AWS infrastructure
* Version-controlled infrastructure configuration

**Observability**

* Application metrics
* Kubernetes metrics
* Centralized logging
* Distributed tracing
* Dashboards
* Alerting
* OpenTelemetry

---

# Project Attribution

This project is based on the **Learn to Cloud Journal Starter** repository.

The starter repository provided the initial FastAPI journal application used as the foundation for the project.

I extended the application with additional API functionality, validation, logging, AI integration, automated testing, and code-quality improvements before evolving it into the cloud and DevOps platform documented here.

The infrastructure, containerization, AWS deployment architecture, Terraform configuration, Kubernetes platform, CI/CD pipeline, HTTPS/DNS integration, persistent storage, and observability implementation represent the broader cloud and DevOps engineering work completed as part of this project.

---

# Project Goal

The goal of this project is to demonstrate the complete lifecycle of operating a backend application using modern cloud and DevOps practices, from infrastructure provisioning and containerization to automated deployment, Kubernetes orchestration, monitoring, logging, and distributed tracing.

The project provides hands-on experience with the technologies and operational practices commonly used in Cloud Engineering, DevOps Engineering, Platform Engineering, and Site Reliability Engineering environments.

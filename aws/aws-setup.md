# AWS Setup Guide

## Project Overview

TodoSummaryAssistant is a containerized application with a React frontend, Spring Boot backend, and MySQL database.

## AWS Architecture

The planned AWS deployment uses:

- **Amazon VPC:** Isolated network for application resources.
- **Amazon EC2:** Hosts the Docker containers.
- **Amazon RDS for MySQL:** Managed relational database in private subnets.
- **Security Groups:** Control inbound and outbound traffic.
- **Amazon CloudWatch:** Intended for monitoring AWS resources.

## Network Design

- Public subnets are intended for resources requiring internet access.
- Private subnets are intended for the database.
- The database should not be publicly accessible.
- Database access should be restricted to the application server's security group.

## Application Deployment

The repository contains a Jenkins pipeline and an EC2 deployment script intended to automate image deployment and health checks.

Deployment must be configured with valid database connection settings and deployment credentials before it can run successfully.

## Security Notes

- Store database passwords and API keys outside Git.
- Never commit private SSH keys or AWS access keys.
- Use least-privilege security group rules.
- Keep the database private.

## Implementation Status

This guide describes the intended architecture and setup. Update this section as each AWS component and deployment step is verified.

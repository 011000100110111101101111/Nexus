# Deploying Postgressql via helm chart

[toc]

## General Information

### Open Ports

None externally, internally 5432. 

Can expose to external via helm chart option or creating a service for it (There is an example service file for it in the helm folder, can adapt this to any deployment type.)

## Known Requirements

## Installation

```bash
# Installation
helm install postgres oci://registry-1.docker.io/bitnamicharts/postgresql-ha --version 12.2.0 -f postgres-values.yml

# Testing Connection
psql -h <ip> -U <user> -d <database>

# The defaults are the following
psql -h <ip> -U postgres -d postgres
```

## Troubleshooting Commands

## Troubleshooting Topics

## Resources
# Failure and Rollback Plan

## 1. Faulty version deployed
Identify the failed Jenkins build and image tag. Inspect `sudo docker ps -a` and `sudo docker logs --tail 200 <container>`. Re-deploy the last known-good immutable image tag, recreate the container with the documented environment and network, then verify backend health and frontend CRUD operations. Keep prior image tags available. Database schema changes may not be reversible by application rollback alone.

## 2. Application crashes
Containers started with `--restart unless-stopped` are restarted by Docker after exit or host restart. This is not health-based recovery. Check container state, exit code, logs, memory, disk, database connectivity, and health endpoint. If restart loops continue, roll back and investigate.

## 3. CI/CD unavailable
Use a known-good, already-published immutable image tag as a controlled break-glass procedure: pull on EC2, recreate the container using the documented environment file/network, run health and functional checks, and document the manual deployment. Never put secrets in command history or Git. Reconcile the manual deployment when CI/CD returns.

## 4. Secrets leaked
Immediately revoke/rotate the credential, update the secret store or EC2 environment file, restart affected services, review GitHub/Jenkins/AWS/application logs for misuse, remove the secret from tracked files/history as appropriate, and document the incident. A new commit alone does not invalidate a leaked credential.

## 5. EC2 fails
Check EC2 status checks, system logs, and volume status. If unrecoverable, launch a replacement with the documented OS, subnet, security group, and IAM role; install Docker, pull known-good images, recreate the protected environment file, connect to RDS, and verify health. Update DNS/IP references if applicable.

## 6. RDS unavailable
Database-dependent operations fail. Check RDS events/status/metrics, security groups, connectivity, and application logs. Restore from automated backup or snapshot if needed, securely update the endpoint/credentials, and verify application health and data. This setup was created Single-AZ; do not claim Multi-AZ failover unless enabled and verified. Backups and snapshots may incur charges.

## Validation checklist
- [ ] Known-good image tags recorded
- [ ] Backend health verified
- [ ] Frontend and CRUD operations verified
- [ ] Backup/restore approach documented
- [ ] Secret rotation understood
- [ ] Recovery commands tested or explicitly marked untested

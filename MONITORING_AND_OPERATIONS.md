# Monitoring and Operations

The assessment requires application metrics, host metrics, a Grafana dashboard, and at least two meaningful alerts. Files in `monitoring/` are starter configuration; monitoring is not complete until services, targets, dashboards, and alerts are verified in the running environment.

## Metrics

- Application: request rate, latency, HTTP errors, Spring health, JVM memory/GC, database pool failures.
- Host: CPU, load, available memory/swap, disk, network.
- Containers: up/down, restarts, CPU/memory, deployed image tag.

## Important logs

- Backend: `sudo docker logs --tail 200 todo-backend`
- Frontend: `sudo docker logs --tail 200 todo-frontend`
- Jenkins Console Output
- Docker service: `sudo journalctl -u docker --since "1 hour ago"`
- RDS events/metrics in AWS console

Never include passwords, tokens, or secret-bearing environment output in logs/screenshots.

## Alerts

The included Prometheus rules cover backend target down, high host CPU, and low disk space. Tune thresholds/durations to avoid noise. Each alert should provide a summary, impact, and first troubleshooting step.

## Early response

Check Prometheus targets and Grafana, correlate application errors with restarts/host saturation/RDS events, inspect logs, roll back to a known-good image if release-related, then verify health and a representative todo API operation.

## Known monitoring work still required

The observed Spring Boot logs exposed only one Actuator endpoint (health); `/actuator/prometheus` was not confirmed. Add/verify Micrometer Prometheus registry and expose `prometheus` through Actuator, keep it private, configure Node Exporter, Prometheus and Grafana, import the dashboard, validate alerts, and capture real screenshots. cAdvisor is optional.

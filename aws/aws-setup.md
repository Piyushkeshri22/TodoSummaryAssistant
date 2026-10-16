# AWS Setup — Todo Summary Assistant

> Review all values against the AWS console before submission. Never commit passwords, access keys, private keys, or secret values.

## Resources observed during setup

- Region: `ap-south-1` (Mumbai)
- VPC: `todo-assistant-vpc-vpc`, CIDR `10.0.0.0/16`
- Host: Ubuntu EC2, `t3.micro`
- Database: RDS MySQL 8.4, identifier `todo-assistant-db`
- Database: `todo_db`, user `todoadmin`
- RDS endpoint: `todo-assistant-db.cneyqcgikrp1.ap-south-1.rds.amazonaws.com:3306`
- RDS public access: Disabled
- Backend image: `piyushkeshri22/todo-backend:8`
- Frontend image: `piyushkeshri22/todo-frontend:9` was published by Jenkins; verify it was pulled, started, and tested before claiming frontend deployment complete.

## Networking

The VPC uses a public subnet for EC2 and private subnets for RDS:

- `10.0.128.0/20` — private subnet in `ap-south-1a`
- `10.0.144.0/20` — private subnet in `ap-south-1b`

The public route table routes internet-bound traffic through an Internet Gateway. RDS remains in private subnets and must not be publicly accessible.

## Security groups

### `todo-assistant-ec2-sg`

- SSH TCP/22 restricted to administrator's public IP `/32`; browser EC2 Instance Connect also required the regional managed prefix list.
- HTTP TCP/80 open for public web traffic.
- Do not open SSH to `0.0.0.0/0`.
- Backend port must not be publicly reachable.

### `todo-assistant-rds-sg`

- MySQL TCP/3306 inbound only from `todo-assistant-ec2-sg`.
- Public access disabled; no public MySQL inbound rule.
- Verify final inbound and outbound rules in the AWS console.

## Verified observations

- EC2 connected to the private RDS endpoint using the MySQL client.
- Backend logs showed Hikari connection pool started, Hibernate initialized, and Spring Boot started on port 8080.
- `curl http://127.0.0.1:8081/actuator/health` returned HTTP 200.
- `todo_db` was created before starting the backend; Hibernate uses `spring.jpa.hibernate.ddl-auto=update`.

## Secrets and IAM

- Database password is in an EC2-local `.env` file with mode `600`; never commit it.
- Optional Cohere and Slack values should remain empty unless configured.
- Docker Hub credentials are stored in Jenkins Credentials.
- Verify the EC2 instance has a least-privilege IAM instance profile; do not store AWS access keys on the instance.
- Rotate any credential that was accidentally exposed.

## Cost

EC2, RDS, storage, and public IPv4 can incur charges. Check Billing and delete assessment resources when no longer needed. Snapshots may also cost money.

# mysqlexports_secretsmanager_POC

## Overview

This script demonstrates a secure way to export a MySQL database by retrieving credentials from AWS Secrets Manager at runtime. It avoids hardcoding passwords and promotes best practices for security and operational automation.

---

## Why Use a Secrets Manager Instead of Hardcoded Passwords or Environment Variables?

### 1. **Security Risk of Hardcoded Passwords**
- **Exposure Risk**: Hardcoded passwords can easily be leaked if the script is shared, committed to source control (e.g., Git), or accessed by unauthorized users.
- **No Easy Rotation**: Updating passwords requires editing every script, redeploying them, and coordinating changes across systems.

### 2. **Issues with Environment Variables**
- **Persistence**: Environment variables can be accidentally exposed via logs, process listings (`ps` commands), or misconfigurations.
- **Rotation Difficulty**: Changing an environment variable across many servers can be error-prone and requires downtime or restarts.
- **Local Scope**: Difficult to enforce consistent and secure practices across environments (dev, QA, prod).

### 3. **Advantages of AWS Secrets Manager**
- **Centralized Secret Management**: All credentials are stored securely and managed centrally.
- **Audit and Compliance**: AWS logs access to secrets via CloudTrail, enabling compliance and monitoring.
- **Automatic Rotation**: Secrets Manager can rotate secrets automatically without needing to update your scripts.
- **Granular Access Control**: Use AWS IAM policies to tightly control who/what can access a secret.
- **Encryption at Rest and In-Transit**: Secrets are encrypted using AWS KMS.

Using AWS Secrets Manager ensures that secrets are securely retrieved when needed, without being exposed or statically stored.

---


## Requirements

- **AWS CLI**: Installed and configured to access Secrets Manager.
- **jq**: Installed for JSON parsing.
- **MySQL client tools**: (`mysqldump`) must be available.

---

## Quick Usage Notes

- Update the following variables:
  - `SECRET_NAME` with your actual AWS Secrets Manager secret.
  - `DATABASE` with the database you want to export.
  - `EXPORT_DIR` if you want to change the export location.
- The script will:
  1. Fetch credentials securely.
  2. Export the database.
  3. Archive the SQL file as a `.tar.gz`.

---

## Example Cron Job

```bash
# Run the export script daily at 2 AM
0 2 * * * /path/to/mysql_export_with_secrets.sh >> /var/log/mysql_export.log 2>&1
```

---

## Security Notes

- No credentials are stored on disk.
- Secrets are fetched just-in-time.
- Secrets Manager provides fine-grained access control and audit trails.
- Ensure IAM roles are tightly scoped to limit who and what can retrieve secrets.

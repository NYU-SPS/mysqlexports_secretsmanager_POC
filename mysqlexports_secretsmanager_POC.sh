#!/bin/bash

# Script Name: mysql_export_with_secrets.sh
# Purpose: Securely export a MySQL database using credentials from AWS Secrets Manager
# Author: Rick Heiss rheiss@gmail.com rh1217@nyu.edu https://github.com/rheiss

# ---------------------------
# Configuration
# ---------------------------
SECRET_NAME="mysql/export-user-password/prod"    # Update with your secret's name
REGION="us-east-1"                        # AWS Region where Secrets Manager is hosted
DATABASE="your_database_name"             # Database to export
EXPORT_DIR="/home/exports"                # Directory to store exports
MYSQLDUMP_OPTIONS="--single-transaction --quick --lock-tables=false"  # Options for mysqldump

# ---------------------------
# Fetch MySQL credentials
# ---------------------------
echo "[INFO] Fetching database credentials from Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region "$REGION" \
    --query SecretString \
    --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r .username)
DB_PASS=$(echo "$SECRET_JSON" | jq -r .password)

# Validate credentials
if [[ -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "[ERROR] Failed to retrieve database credentials. Exiting."
    exit 1
fi

# ---------------------------
# Prepare Export Directory
# ---------------------------
echo "[INFO] Preparing export directory..."
mkdir -p "$EXPORT_DIR"
rm -rf "$EXPORT_DIR"/*

# ---------------------------
# Export Database
# ---------------------------
EXPORT_FILE="$EXPORT_DIR/${DATABASE}_$(date +%Y%m%d_%H%M%S).sql"
echo "[INFO] Exporting database '$DATABASE' to '$EXPORT_FILE'..."

mysqldump -h localhost -u "$DB_USER" -p"$DB_PASS" $MYSQLDUMP_OPTIONS "$DATABASE" > "$EXPORT_FILE"

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Database export failed."
    exit 1
fi

# ---------------------------
# Archive Export (Optional)
# ---------------------------
echo "[INFO] Archiving export file..."
tar -czvf "${EXPORT_FILE}.tar.gz" -C "$EXPORT_DIR" "$(basename "$EXPORT_FILE")"
rm -f "$EXPORT_FILE"

echo "[SUCCESS] Database export and archive completed successfully."

exit 0
```

---

#!/usr/bin/env bash
set -euo pipefail

# Enable logging for debugging
exec > >(tee /var/log/bootstrap-postgres.log) 2>&1
echo "Starting PostgreSQL bootstrap script at $(date)"

pg_version="${pg_version}"
db_name="${db_name}"
db_owner="${db_owner}"
db_owner_password="${db_owner_password}"
listen_addresses="${listen_addresses}"
port="${port}"
ldap_domain_fqdn="${ldap_domain_fqdn}"
ldap_bind_dn="${ldap_bind_dn}"
ldap_bind_password="${ldap_bind_password}"
ldap_search_base="${ldap_search_base}"
ldap_server_host="${ldap_server_host}"

export DEBIAN_FRONTEND=noninteractive
echo "Updating package lists..."
apt-get update -y
echo "Installing prerequisites..."
apt-get install -y wget curl ca-certificates gnupg lsb-release

# Add PGDG repository to ensure requested PostgreSQL version is available
echo "Adding PostgreSQL official repository..."
install -d /usr/share/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
echo "Updating package lists after adding PostgreSQL repo..."
apt-get update -y
echo "Installing PostgreSQL version ${pg_version} and LDAP utilities..."
apt-get install -y postgresql-${pg_version} ldap-utils
echo "PostgreSQL installation completed successfully"

# First, start PostgreSQL with default configuration
echo "Starting PostgreSQL with default configuration..."
systemctl enable postgresql
systemctl start postgresql

# Wait for PostgreSQL to be ready with default config
echo "Waiting for PostgreSQL to start with default configuration..."
for i in {1..30}; do
    if sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
        echo "PostgreSQL is running with default configuration"
        break
    fi
    echo "Waiting for PostgreSQL to start... ($i/30)"
    sleep 2
done

# Now configure PostgreSQL
echo "Configuring PostgreSQL..."
pg_hba="/etc/postgresql/${pg_version}/main/pg_hba.conf"
postgresql_conf="/etc/postgresql/${pg_version}/main/postgresql.conf"

sed -i "s/^#\?listen_addresses.*/listen_addresses = '${listen_addresses}'/" "$postgresql_conf"
sed -i "s/^#\?port.*/port = ${port}/" "$postgresql_conf"

# Backup original pg_hba.conf
cp "$pg_hba" "$pg_hba.backup"

# Add LDAP configuration
echo "# LDAP auth via AD" >> "$pg_hba"
echo "host    all             all             0.0.0.0/0               ldap ldapserver=${ldap_server_host} ldapport=389 ldapbasedn=\"${ldap_search_base}\" ldapbinddn=\"${ldap_bind_dn}\" ldapbindpasswd=\"${ldap_bind_password}\"" >> "$pg_hba"

# Test configuration before restarting
echo "Testing PostgreSQL configuration..."
if ! sudo -u postgres /usr/lib/postgresql/${pg_version}/bin/postgres --config-file="$postgresql_conf" --check-config >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL configuration has syntax errors"
    echo "Restoring backup configuration..."
    cp "$pg_hba.backup" "$pg_hba"
    exit 1
fi

# Restart PostgreSQL to apply configuration
echo "Restarting PostgreSQL to apply configuration..."
systemctl restart postgresql@${pg_version}-main

# If restart fails, restore backup and retry
if [ $? -ne 0 ]; then
    echo "Restart failed, restoring backup configuration..."
    cp "$pg_hba.backup" "$pg_hba"
    systemctl restart postgresql@${pg_version}-main
    echo "PostgreSQL restarted with backup configuration"
fi

echo "Waiting for PostgreSQL to be ready..."
# Wait for PostgreSQL to be ready (up to 60 seconds)
for i in {1..60}; do
    if sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "Waiting for PostgreSQL to start... ($i/60)"
    sleep 1
done

# Final check
if ! sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL failed to start properly"
    echo "Main postgresql service status:"
    systemctl status postgresql
    echo "PostgreSQL 16 cluster status:"
    systemctl status postgresql@16-main
    echo "Checking if cluster is running manually:"
    sudo -u postgres pg_lsclusters
    exit 1
fi

echo "Creating database and user..."
sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${db_owner}') THEN
      CREATE ROLE ${db_owner} LOGIN PASSWORD '${db_owner_password}';
   END IF;
END
$$;

CREATE DATABASE ${db_name} OWNER ${db_owner};
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_owner};
SQL

echo "PostgreSQL bootstrap script completed successfully at $(date)"



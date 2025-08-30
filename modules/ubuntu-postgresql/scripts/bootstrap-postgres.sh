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

# Add LDAP configuration BEFORE existing host rules
# Create a temporary file with LDAP rules first
temp_hba=$(mktemp)

# Write header comments first
head -n 90 "$pg_hba" > "$temp_hba"

# Add LDAP configuration
echo "" >> "$temp_hba"
echo "# LDAP authentication for Active Directory users" >> "$temp_hba"
echo "# This must come BEFORE other host rules" >> "$temp_hba"
echo "host    all             all             0.0.0.0/0               ldap ldapserver=${ldap_server_host} ldapport=389 ldapbasedn=\"${ldap_search_base}\" ldapbinddn=\"${ldap_bind_dn}\" ldapbindpasswd=\"${ldap_bind_password}\" ldapsearchattribute=sAMAccountName" >> "$temp_hba"
echo "" >> "$temp_hba"

# Add the rest of the original file (the actual host rules)
tail -n +91 "$pg_hba" >> "$temp_hba"

# Replace the original file
mv "$temp_hba" "$pg_hba"

# Restart PostgreSQL to apply configuration
echo "Restarting PostgreSQL to apply configuration..."
systemctl restart postgresql@${pg_version}-main

# Test if restart was successful by checking if we can connect
sleep 3
if ! sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
    echo "Restart failed or PostgreSQL not responding, restoring backup configuration..."
    cp "$pg_hba.backup" "$pg_hba"
    systemctl restart postgresql@${pg_version}-main
    sleep 3
    if sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
        echo "PostgreSQL restarted successfully with backup configuration"
    else
        echo "ERROR: PostgreSQL failed to start even with backup configuration"
        systemctl status postgresql@${pg_version}-main
        exit 1
    fi
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

# Check if user exists and create if not
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${db_owner}'" | grep -q 1; then
    echo "Creating user ${db_owner}..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE ${db_owner} LOGIN PASSWORD '${db_owner_password}';"
else
    echo "User ${db_owner} already exists"
fi

# Check if database exists and create if not
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw ${db_name}; then
    echo "Creating database ${db_name}..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE DATABASE ${db_name} OWNER ${db_owner};"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_owner};"
else
    echo "Database ${db_name} already exists"
fi

# Create PostgreSQL roles for LDAP users (without passwords - they'll auth via LDAP)
echo "Creating PostgreSQL roles for LDAP users..."

# Create role for azureadmin (AD admin user)
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='azureadmin'" | grep -q 1; then
    echo "Creating LDAP role for azureadmin..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE azureadmin LOGIN;"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "GRANT CONNECT ON DATABASE ${db_name} TO azureadmin;"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "GRANT USAGE ON SCHEMA public TO azureadmin;"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "GRANT CREATE ON SCHEMA public TO azureadmin;"
else
    echo "LDAP role azureadmin already exists"
fi

# Create role for pgbind user (if they need database access)
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='pgbind'" | grep -q 1; then
    echo "Creating LDAP role for pgbind..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE pgbind LOGIN;"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -c "GRANT CONNECT ON DATABASE ${db_name} TO pgbind;"
else
    echo "LDAP role pgbind already exists"
fi

echo "PostgreSQL bootstrap script completed successfully at $(date)"



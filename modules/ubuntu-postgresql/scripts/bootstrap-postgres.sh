#!/usr/bin/env bash
set -euo pipefail

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
apt-get update -y
apt-get install -y wget curl ca-certificates gnupg lsb-release

# Add PGDG repository to ensure requested PostgreSQL version is available
install -d /usr/share/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get update -y
apt-get install -y postgresql-${pg_version} ldap-utils

pg_hba="/etc/postgresql/${pg_version}/main/pg_hba.conf"
postgresql_conf="/etc/postgresql/${pg_version}/main/postgresql.conf"

sed -i "s/^#\?listen_addresses.*/listen_addresses = '${listen_addresses}'/" "$postgresql_conf"
sed -i "s/^#\?port.*/port = ${port}/" "$postgresql_conf"

cat >> "$pg_hba" <<EOF
# LDAP auth via AD
host    all             all             0.0.0.0/0               ldap ldapserver=${ldap_server_host} ldapport=389 ldapprefix= uid= ldapsuffix=,${ldap_search_base} ldapbasedn=${ldap_search_base} ldapbinddn=${ldap_bind_dn} ldapbindpasswd=${ldap_bind_password}
EOF

systemctl enable postgresql
systemctl restart postgresql

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



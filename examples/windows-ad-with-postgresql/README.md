### Example: Windows AD Domain Controller with Ubuntu PostgreSQL (LDAP)

This example provisions:
- A resource group and VNet (self-service modules)
- A Windows Server 2025 AD DS domain controller
- An Ubuntu VM with PostgreSQL 16.7 configured for LDAP against the AD

Terraform Cloud usage (no local init/apply)
1. Create a Terraform Cloud workspace connected to this repo.
2. Set the Workspace Working Directory to `examples/windows-ad-with-postgresql`.
3. Variables (Terraform variables):
   - `subscription_id` (string)
   - `config_json` (string) → `./config.example.json` or your own JSON path committed in this directory
4. Variables (Environment, for Azure auth via Service Principal):
   - `ARM_TENANT_ID`
   - `ARM_SUBSCRIPTION_ID` (optional if you pass `subscription_id` var)
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET` (mark as sensitive)
5. Queue a run. TFC will plan/apply per your workspace settings.

Configuration
- Update `config.example.json` (or your copied JSON) to customize sizes, network ranges, and secrets.

Using terraform-mcp-server for docs
- You can generate input/output reference by pointing the MCP server at this repo and asking it to summarize module variables and outputs.
- Example prompt:
```
Summarize inputs and outputs for modules/windows-ad-domain-controller and modules/ubuntu-postgresql and render Markdown tables.
```



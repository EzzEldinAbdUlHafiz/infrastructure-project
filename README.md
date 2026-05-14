# Infrastructure project

This repository provisions a small AWS stack with **Terraform** and deploys a **Flask** application with **Ansible**. The app runs behind **nginx** (HTTPS with a self-signed certificate) and connects to **Amazon RDS for PostgreSQL** in private subnets.

## What gets deployed

- **Networking**: VPC (`10.0.0.0/16`), public subnet for the web server, two private subnets for RDS, internet gateway, and public route table.
- **Compute**: Single EC2 instance (Ubuntu-style workflow in Ansible; set an appropriate AMI in Terraform).
- **Database**: PostgreSQL 15 on RDS (`db.t3.micro`), not publicly accessible; security group allows PostgreSQL only from the web security group.
- **Edge**: Security groups for SSH (configurable CIDR), HTTP/HTTPS from the internet, and RDS ingress from the web instance only.

## Repository layout

| Path | Purpose |
|------|---------|
| `terraform/` | Root module plus `modules/ec2`, `modules/rds`, `modules/security_groups` |
| `ansible/` | Playbook, inventory, roles (`flask_app`, `nginx`), group vars, Ansible Vault file for secrets |
| `app.py` | Minimal Flask API with `/` and `/health` (database check via `DATABASE_URL`) |
| `requirements.txt` | Runtime dependencies (Flask, Gunicorn, psycopg2, python-dotenv) |

## Prerequisites

- [Terraform](https://www.terraform.io/) (AWS provider `~> 6.0`)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- AWS account, IAM credentials configured (for example via `AWS_PROFILE` or environment variables)
- An EC2 key pair in the target region (Terraform variable `key_name`)
- SSH private key matching that pair (this repo’s Ansible config expects `../key.pem` relative to the `ansible/` directory)

## Terraform

1. Copy the example variables file and edit values (especially AMI, key pair, database password, and SSH CIDR):

   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Initialize and apply from `terraform/`:

   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. Note the outputs:

   - `ec2_public_ip` — use as the Ansible target host in `ansible/inventory.yml`.
   - `rds_endpoint` — use as `vault_db_host` in Ansible Vault (hostname portion only; the Terraform output includes port).

Use an AMI appropriate for your region and OS (the example in `terraform.tfvars.example` is illustrative; replace it before applying).

## Ansible

The playbook `ansible/site.yml` runs on group `webservers` and applies roles in order: `flask_app`, then `nginx`.

### Inventory

Point `ansible/inventory.yml` at the EC2 public IP (or DNS) from Terraform. The sample layout uses `ansible_user: ubuntu` and `ansible_ssh_private_key_file: "../key.pem"`.

### Secrets (Ansible Vault)

`ansible/group_vars/vault.yml` is referenced by the playbook and should define variables used by `roles/flask_app/templates/env.j2`:

- `vault_db_user` — PostgreSQL user (match Terraform `db_username` unless you changed it)
- `vault_db_password` — PostgreSQL password (match Terraform `db_password`)
- `vault_db_host` — RDS endpoint host (from `terraform output -raw rds_endpoint`, without `:5432` if you split host and port)
- `vault_db_name` — Database name (Terraform `db_name`)
- `vault_flask_secret_key` — Flask `SECRET_KEY`

Encrypt the file for version control:

```bash
cd ansible
ansible-vault encrypt group_vars/vault.yml
```

`ansible/ansible.cfg` sets `vault_password_file = .vault-pass` for local convenience. **Do not commit `.vault-pass` or plaintext secrets**; they are listed in `.gitignore`.

### Run the playbook

From the `ansible/` directory (after inventory and vault are ready):

```bash
cd ansible
ansible-playbook site.yml
```

**What the roles do**

- **flask_app**: Installs Python tooling, creates `flaskuser` and `/opt/flask-app`, copies `app.py` and `requirements.txt` from the repo root, creates a venv, writes `.env`, installs and starts a `systemd` unit running Gunicorn on `127.0.0.1:8000`.
- **nginx**: Installs nginx, generates a self-signed TLS certificate, proxies HTTPS to the local Gunicorn port, redirects HTTP to HTTPS, and disables the default site.

After deployment, open `https://<EC2_PUBLIC_IP>/` (accept the browser warning for the self-signed certificate). Health check: `https://<EC2_PUBLIC_IP>/health`.

## Local development

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL="postgresql://user:pass@host:5432/dbname"
export SECRET_KEY="dev-secret"
python app.py
```

The app listens on `0.0.0.0:8000` when run directly; production uses Gunicorn behind nginx.

## Security notes

- Restrict `ssh_allowed_cidrs` in `terraform.tfvars` to your IP or bastion range instead of `0.0.0.0/0` in real environments.
- Keep `key.pem`, `terraform.tfstate`, `*.tfvars`, and Ansible vault passwords out of git (see `.gitignore`).
- TLS uses a **self-signed** certificate from Ansible; replace with ACM or another CA-backed certificate for production browsers and automation.

## Optional role documentation

Role-specific README files live under `ansible/roles/flask_app/README.md` and `ansible/roles/nginx/README.md`.

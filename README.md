# Blyss App

Simple FastAPI app located in `blyss-app/`.

## Local Run

Requirements:
- Python 3.12+
- `uv`

Commands:

```bash
cd blyss-app
uv sync --extra dev
uv run uvicorn main:app --reload
```

Open:
- `http://127.0.0.1:8000/`
- `http://127.0.0.1:8000/api/health/live`

## Docker Run (Dev Compose)

```bash
cd blyss-app
docker compose -f docker/docker-compose.yaml up --build
```

## Docker Run (Prod-like Compose)

```bash
cd blyss-app
docker compose -f docker/docker-compose.prod.yaml up --build -d
```

Stop:

```bash
docker compose -f docker/docker-compose.yaml down
docker compose -f docker/docker-compose.prod.yaml down
```

## Terraform Deployment (Prod)

1. Create ACM certificate in the same AWS region for:
   - `api.karkidhan.com.np`
   - `*.karkidhan.com.np` (if needed)
2. Complete DNS validation and confirm certificate status is `ISSUED`.
3. Update values in `terraform/live/prod/terraform.tfvars` if needed.
4. Configure AWS credentials/profile used by `terraform/live/prod/providers.tf`.
5. Deploy:

```bash
cd terraform/live/prod
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

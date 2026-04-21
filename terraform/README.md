# Terraform Deploy (Prod)

1. Create ACM certificate first (in the same region) for:
   - `api.karkidhan.com.np`
   - `*.karkidhan.com.np` (if needed)
2. Ensure DNS validation is completed and certificate status is `ISSUED`.
3. Update `live/prod/terraform.tfvars` values if needed.
4. Configure AWS credentials/profile used by `live/prod/providers.tf`.
5. Deploy:
   - `cd terraform/live/prod`
   - `terraform init`
   - `terraform plan -out tfplan`
   - `terraform apply tfplan`

## Notes

- Remote state bucket/backends must exist and be accessible.
- Secrets are bootstrapped with placeholder values; update in SSM/Secrets Manager after apply.

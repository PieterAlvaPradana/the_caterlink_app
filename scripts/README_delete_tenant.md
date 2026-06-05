Delete tenant and related orders (safe procedure)

1) Overview
- This provides a Node.js script `delete_tenant_irzimart.js` that performs a dry-run and optionally deletes a tenant by name (default "Irzi Mart") and related documents:
  - Orders where `sellerId` == tenantId in `orders` collection
  - Menu documents under `sellers/{tenantId}/menus`
  - User document in `users/{tenantId}` if exists
  - Tenant document in `tenants/{tenantId}`

2) Precautions
- Always run with `--dry-run` first. Inspect the generated JSON file.
- Back up your Firestore or export data before executing.

3) Requirements
- Node 16+
- Install dependencies:

```bash
npm install firebase-admin minimist
```

4) Setup
- Place your Firebase service account JSON at `scripts/serviceAccountKey.json`, or set env `FIREBASE_SERVICE_ACCOUNT=/path/to/key.json`.

5) Dry-run example

```bash
node scripts/delete_tenant_irzimart.js --name "Irzi Mart" --dry-run
```

Output: `scripts/dryrun_Irzi_Mart.json` with found tenants, orders and menus.

6) Execute deletion (ONLY after verifying dry-run)

```bash
node scripts/delete_tenant_irzimart.js --name "Irzi Mart" --execute
```

7) Notes
- Script deletes user document with same id (common pattern in this repo). If your tenant user id differs, adjust script.
- If your data model uses `sellers` instead of `tenants`, the script searches `tenants` but also deletes menus under `sellers/{id}/menus`.

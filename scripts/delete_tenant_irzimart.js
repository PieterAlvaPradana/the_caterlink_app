/*
 Safe delete script for tenant by name (dry-run first).

 Usage:
 1) Place your service account JSON at ./serviceAccountKey.json or set env FIREBASE_SERVICE_ACCOUNT
 2) Dry-run (list affected docs):
    node scripts/delete_tenant_irzimart.js --name "Irzi Mart" --dry-run
 3) Execute deletion (after verifying dry-run):
    node scripts/delete_tenant_irzimart.js --name "Irzi Mart" --execute

 This script ONLY runs deletions when --execute is provided. Always run with --dry-run first.
*/

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

function loadServiceAccount() {
  const envPath = process.env.FIREBASE_SERVICE_ACCOUNT;
  const defaultPath = path.join(__dirname, 'serviceAccountKey.json');
  const p = envPath || defaultPath;
  if (!fs.existsSync(p)) {
    console.error('Service account file not found at', p);
    process.exit(1);
  }
  return require(p);
}

async function main() {
  const args = require('minimist')(process.argv.slice(2));
  const name = args.name || args.n || 'Irzi Mart';
  const dryRun = !!args['dry-run'] || !!args['dryrun'] || !!args.dry;
  const execute = !!args.execute || !!args.x;

  if (!dryRun && !execute) {
    console.log('Please pass --dry-run to preview deletions or --execute to perform them.');
    process.exit(0);
  }

  const serviceAccount = loadServiceAccount();
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
  const db = admin.firestore();

  console.log(`Searching for tenant name: "${name}"`);
  const nameLower = name.toLowerCase();

  // Query tenants by exact name first
  let tenantsSnapshot = await db.collection('tenants').where('name', '==', name).get();
  let tenants = tenantsSnapshot.docs;

  if (tenants.length === 0) {
    // fallback: case-insensitive scan (costly but safe for small datasets)
    console.log('No exact match; doing case-insensitive scan of tenants collection...');
    const allTenants = await db.collection('tenants').get();
    tenants = allTenants.docs.filter(d => (d.data().name || '').toString().toLowerCase() === nameLower);
  }

  if (tenants.length === 0) {
    console.log('No tenants found matching name:', name);
    process.exit(0);
  }

  const result = { tenants: [] };

  for (const tdoc of tenants) {
    const tid = tdoc.id;
    const tdata = tdoc.data();
    console.log(`Found tenant: id=${tid}, name=${tdata.name}`);

    // Find orders referencing this tenant as sellerId
    const ordersSnap = await db.collection('orders').where('sellerId', '==', tid).get();
    const orders = ordersSnap.docs.map(d => ({ id: d.id, refPath: d.ref.path, data: d.data() }));

    // Find menus under sellers/{tid}/menus (if exists)
    const menusPath = `sellers/${tid}/menus`;
    let menus = [];
    try {
      const menusSnap = await db.collection('sellers').doc(tid).collection('menus').get();
      menus = menusSnap.docs.map(d => ({ id: d.id, refPath: d.ref.path }));
    } catch (e) {
      // ignore if collection absent
    }

    // Check for user document with same id
    const userDoc = await db.collection('users').doc(tid).get();
    const hasUser = userDoc.exists;

    result.tenants.push({ id: tid, data: tdata, ordersCount: orders.length, orders, menusCount: menus.length, menus, hasUser });
  }

  const outPath = path.join(__dirname, `dryrun_${name.replace(/\s+/g,'_')}.json`);
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2));
  console.log(`Dry-run written to ${outPath}`);

  // Print summary
  let totalOrders = 0, totalMenus = 0;
  for (const t of result.tenants) {
    console.log(`Tenant ${t.id}: orders=${t.ordersCount}, menus=${t.menusCount}, user=${t.hasUser}`);
    totalOrders += t.ordersCount;
    totalMenus += t.menusCount;
  }
  console.log(`SUMMARY: tenants=${result.tenants.length}, totalOrders=${totalOrders}, totalMenus=${totalMenus}`);

  if (dryRun && !execute) {
    console.log('Dry-run complete. Re-run with --execute to perform deletions.');
    process.exit(0);
  }

  // Execute deletions
  console.log('Executing deletions...');

  const batchSize = 400;
  for (const t of result.tenants) {
    const tid = t.id;
    // Delete orders
    for (let i = 0; i < t.orders.length; i += batchSize) {
      const batch = db.batch();
      const slice = t.orders.slice(i, i + batchSize);
      for (const od of slice) {
        batch.delete(db.doc(od.refPath));
      }
      await batch.commit();
      console.log(`Deleted ${slice.length} orders for tenant ${tid}`);
    }

    // Delete menus
    for (let i = 0; i < t.menus.length; i += batchSize) {
      const batch = db.batch();
      const slice = t.menus.slice(i, i + batchSize);
      for (const md of slice) {
        batch.delete(db.doc(md.refPath));
      }
      await batch.commit();
      console.log(`Deleted ${slice.length} menus for tenant ${tid}`);
    }

    // Delete user doc if exists
    if (t.hasUser) {
      await db.collection('users').doc(tid).delete();
      console.log(`Deleted user document for ${tid}`);
    }

    // Delete tenant doc
    await db.collection('tenants').doc(tid).delete();
    console.log(`Deleted tenant document ${tid}`);
  }

  console.log('Deletion complete.');
  process.exit(0);
}

main().catch(e => {
  console.error('Error:', e);
  process.exit(1);
});

import pg from 'pg';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// You need to provide the database connection string
// Get it from: https://supabase.com/dashboard/project/obcpynzcyjcdxconyzjm/settings/database
// Format: postgresql://postgres:[YOUR-PASSWORD]@db.obcpynzcyjcdxconyzjm.supabase.co:5432/postgres

const connectionString = process.env.DATABASE_URL || process.argv[2];

if (!connectionString) {
  console.error('Please provide DATABASE_URL environment variable or as first argument');
  console.error('Example: node deploy-migration-pg.js "postgresql://postgres:password@db.obcpynzcyjcdxconyzjm.supabase.co:5432/postgres"');
  process.exit(1);
}

const client = new pg.Client({
  connectionString,
  ssl: { rejectUnauthorized: false }
});

async function runMigration() {
  try {
    console.log('Connecting to database...');
    await client.connect();
    console.log('Connected successfully!');

    console.log('Reading migration file...');
    const migrationSQL = readFileSync(
      join(__dirname, 'supabase', 'migrations', 'combined_migration.sql'),
      'utf-8'
    );

    console.log('Executing migration...');
    console.log('SQL length:', migrationSQL.length, 'characters');

    await client.query(migrationSQL);

    console.log('✅ Migration completed successfully!');
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    console.error('Details:', err);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigration();

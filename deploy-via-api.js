import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const supabaseUrl = 'https://obcpynzcyjcdxconyzjm.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9iY3B5bnpjeWpjZHhjb255emptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Mjk0NjA1MSwiZXhwIjoyMDc4NTIyMDUxfQ.PmEMpiFGw4onbDJ1Rfyrk2q84-3CdRzQs2_yXPXCWxs';

async function runMigration() {
  try {
    console.log('📖 Reading migration file...');
    const migrationSQL = readFileSync(
      join(__dirname, 'supabase', 'migrations', 'combined_migration_fixed.sql'),
      'utf-8'
    );

    console.log(`✅ Read ${migrationSQL.length} characters`);
    console.log('🚀 Executing migration via Supabase REST API...\n');

    // Use Supabase REST API to execute SQL
    const response = await fetch(`${supabaseUrl}/rest/v1/rpc/exec`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({
        query: migrationSQL
      })
    });

    const responseText = await response.text();

    if (!response.ok) {
      console.error('❌ Migration failed!');
      console.error('Status:', response.status, response.statusText);
      console.error('Response:', responseText);
      process.exit(1);
    }

    console.log('✅ Migration completed successfully!');
    console.log('Response:', responseText || '(empty response)');

    console.log('\n📊 Next steps:');
    console.log('1. Update AuthProvider to call create_hr_specialist_profile() after HR signup');
    console.log('2. Update AuthProvider to call create_candidate_profile() after candidate signup');
    console.log('3. Test registration flow');

  } catch (err) {
    console.error('❌ Error:', err.message);
    console.error(err);
    process.exit(1);
  }
}

runMigration();

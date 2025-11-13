import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const supabaseUrl = 'https://obcpynzcyjcdxconyzjm.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9iY3B5bnpjeWpjZHhjb255emptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Mjk0NjA1MSwiZXhwIjoyMDc4NTIyMDUxfQ.PmEMpiFGw4onbDJ1Rfyrk2q84-3CdRzQs2_yXPXCWxs';

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function runMigration() {
  try {
    console.log('Reading migration file...');
    const migrationSQL = readFileSync(
      join(__dirname, 'supabase', 'migrations', 'combined_migration.sql'),
      'utf-8'
    );

    console.log('Executing migration on Supabase...');
    console.log('SQL length:', migrationSQL.length, 'characters');

    // Execute SQL via RPC call
    const { data, error } = await supabase.rpc('exec_sql', {
      sql: migrationSQL
    });

    if (error) {
      console.error('Migration failed:', error);
      process.exit(1);
    }

    console.log('Migration completed successfully!');
    console.log('Result:', data);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

runMigration();

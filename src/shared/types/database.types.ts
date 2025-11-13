// Database types for Supabase
// Generated types will be added here after running migrations

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      // Will be populated after migrations
    }
    Views: {
      // Will be populated after migrations
    }
    Functions: {
      // Will be populated after migrations
    }
    Enums: {
      // Will be populated after migrations
    }
  }
}

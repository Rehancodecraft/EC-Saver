// App Configuration
// This file contains app configuration constants
// Note: Supabase anon key is safe to expose in client apps - it's designed for this purpose
// Row Level Security (RLS) policies on Supabase protect the actual data

class AppConfig {
  // Supabase Configuration
  // The anon key is intentionally public - it only grants access defined by RLS policies
  static const String supabaseUrl = 'https://ssddnidpcjcbajxyhjgg.supabase.co';
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNzZGRuaWRwY2pjYmFqeHloamdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NTQ3MjksImV4cCI6MjA3OTAzMDcyOX0.UcAIUQB5cXnkX5Yc75qmcm_R8_-JdGB-qY6XrfiYbTU';
  
  // App Info
  static const String appName = 'EC Saver';
  static const String appFullName = 'Emergency Cases Saver';
  static const String organization = 'Rescue 1122 Pakistan';
  static const String developerName = 'NexiVault';
  static const String supportEmail = 'support@nexivault.com';
  
  // GitHub Release URL for updates
  static const String githubApiUrl = 'https://api.github.com/repos/Rehancodecraft/EC-Saver/releases/latest';
  
  // Security Settings
  static const bool enableDebugLogs = false; // Set to false for production
  static const bool requireInternet = true; // Internet required for registration
  
  // Database Settings
  static const String databaseName = 'emergency_cases.db';
  static const int databaseVersion = 2;
}

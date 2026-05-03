-- Migration: Add multilingual fields for HEY YAT voice messages
-- Run this in the Supabase SQL editor

ALTER TABLE voice_commands
  ADD COLUMN IF NOT EXISTS canonical_english TEXT,
  ADD COLUMN IF NOT EXISTS original_language TEXT;

ALTER TABLE pending_voice_messages
  ADD COLUMN IF NOT EXISTS canonical_english TEXT,
  ADD COLUMN IF NOT EXISTS original_language TEXT;

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS original_language TEXT;

ALTER TABLE incidents
  ADD COLUMN IF NOT EXISTS original_language TEXT;

ALTER TABLE owner_preferences
  ADD COLUMN IF NOT EXISTS original_language TEXT;

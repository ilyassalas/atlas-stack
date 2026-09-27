-- Runs once, the first time Postgres starts with an empty volume.
-- Creates a separate database for your own tables and embeddings,
-- so they don't mix with n8n's internal tables.
CREATE DATABASE atlas;
\connect atlas
CREATE EXTENSION IF NOT EXISTS vector;

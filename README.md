# atlas-stack

Production stack for an AI booking & support agent — **n8n, PostgreSQL + pgvector, Caddy (HTTPS), Docker Compose**, self-hosted on an OVH VPS (Ubuntu 24.04).

It runs **Conduite Atlas**, an AI agent for a *fictional* French driving school. It answers prospects' questions, books appointments, and logs leads.

**Live demo:** https://salaspartners.com/demo (in French, demo school only; don't enter real personal data)

---

## What the agent does

- **Answers questions from a knowledge base (RAG):** prices, packages, required documents, opening hours, financing. Retrieval uses pgvector embeddings stored in PostgreSQL. If the answer isn't in the knowledge base, the agent says so instead of inventing one.
- **Books appointments** in Google Calendar: checks free slots and refuses double bookings.
- **Logs every lead** (name, phone, need) in Google Sheets.
- **Remembers the conversation:** chat memory is stored in PostgreSQL, so it survives restarts.
- **Knows today's date:** the current date is injected into the prompt so "next Tuesday" resolves correctly.
- Model: OpenAI `gpt-5-mini`, via an n8n Tools Agent.

## Architecture

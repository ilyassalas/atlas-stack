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

Browser (salaspartners.com/demo)
│ HTTPS
▼
Caddy ── automatic Let’s Encrypt certificates
│
▼
n8n ── AI agent workflow (Tools Agent)
│ ├─ OpenAI (chat model + embeddings)
│ ├─ Google Calendar (booking)
│ └─ Google Sheets (lead log)
▼
PostgreSQL 16 + pgvector
├─ n8n data (workflows, executions)
├─ chat memory
├─ knowledge-base embeddings
└─ usage limits


Only Caddy is exposed to the internet. n8n and PostgreSQL are reachable only inside Docker's internal network.

## Security and abuse protection

- **No secrets in Git.** All secrets live in `.env` on the server only; `.env` is in `.gitignore`. `.env.example` lists the variables without values.
- **PostgreSQL is never published.** No `ports:` on the database container.
- **Firewall (ufw):** only SSH (22), HTTP (80) and HTTPS (443) are open.
- **SSH:** key-based login; password login disabled.
- **Pinned n8n version:** set in `.env` (`N8N_VERSION`), so updates happen only when I choose.
- **Public demo limits, enforced server-side in PostgreSQL:** 15 messages per session, 100 messages per day overall.
- **CORS** locked to `salaspartners.com`, so the chat endpoint can't be embedded on other sites.

## Monitoring

- **Error workflow:** any failed execution of the agent triggers a separate n8n workflow that emails me the workflow name, the failing node, the error message and a link to the execution.
- **Retry On Fail** on the Google Calendar and Google Sheets nodes (3 tries, 2 s apart) to absorb temporary API errors.
- Tested end to end with a webhook → Stop and Error workflow.

## Repository files

| File | Purpose |
|---|---|
| `docker-compose.yml` | The three services: Caddy, n8n, PostgreSQL + pgvector |
| `Caddyfile` | HTTPS reverse proxy for `n8n.salaspartners.com` |
| `.env.example` | Required variables, without values |
| `.gitignore` | Keeps `.env` out of Git |

## Run it

```bash
git clone https://github.com/<your-username>/atlas-stack.git
cd atlas-stack
cp .env.example .env
# generate secrets
sed -i "s/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)/" .env
sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$(openssl rand -hex 24)/" .env
chmod 600 .env
docker compose up -d
docker compose ps
```

Then open `https://<your-domain>` and create the n8n owner account immediately.

**Requirements:** a VPS with Docker, a DNS A record pointing your subdomain to the server, and ports 80/443 open.

## Operations

```bash
# apply config changes pushed to GitHub
cd ~/atlas-stack && git pull && docker compose up -d

# check status and logs
docker compose ps
docker compose logs --tail=50 n8n
```

⚠️ Never run `docker compose down -v`: `-v` deletes the volumes (database, workflows, credentials).
⚠️ Keep `N8N_ENCRYPTION_KEY` safe: without it, saved credentials can't be decrypted.

## Next steps

- [ ] `agent_runs` table: log every conversation for analysis with SQL
- [ ] 20-question test set and `evaluation.md` (pass rate, cost per conversation)
- [ ] Export the agent workflows to `workflows/` (credentials stripped)
- [ ] 60–90 s demo video
- [ ] Automated backups with a tested restore

---

Built by Ilyas Salas · [salaspartners.com](https://salaspartners.com)

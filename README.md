# StefaLoveApp

Romantic couple app prototype.

Current production prototype is a single-page app in `index.html`, hosted on GitHub Pages and backed by Supabase.

## MVP Direction

We are moving from a personal app for one couple to a beta for real couples:

- paired accounts
- invite codes
- SOS kisses / hugs / attention requests
- mood check-ins
- shared wishes
- basic couple statistics
- a small set of games and love letters

See `docs/mvp-roadmap.md`.

## Supabase

The new beta data model starts in:

```text
supabase/migrations/001_couples_mvp.sql
```

Apply it in the Supabase SQL editor before wiring the new onboarding and SOS UI.

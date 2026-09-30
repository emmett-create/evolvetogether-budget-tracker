-- Run this in Supabase → SQL Editor (project uymgsztjepqpohrcpfet — EvolveTogether's
-- own project).
--
-- evolvetogether_budget_entries already exists with the DocuSign inbox
-- columns (status, source, category made nullable) from an earlier build —
-- this is ONLY the new Lumanu layer (2026-09-30), written as idempotent
-- ADD COLUMN IF NOT EXISTS statements so it's safe to run even if a column
-- below already happens to exist.
--
-- Every campaign here is influencer spend, including additional_paid
-- (uncapped, brand-paid, excluded from the $50k program total but still a
-- real payout) — there's no separate shipping bucket — so every confirmed
-- row is Lumanu-eligible once it has a source ('invoice_email') or attached
-- invoice. See PAID_CATS in docs/app.js.

ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'confirmed';
ALTER TABLE evolvetogether_budget_entries ALTER COLUMN category DROP NOT NULL;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'manual';

ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS billing_id text;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS due_date date;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS po_number text;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS lumanu_status text NOT NULL DEFAULT 'not_sent'
  CHECK (lumanu_status IN ('not_sent','needs_approval','approved','pending','issued','canceled'));
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS lumanu_payable_id text;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS invoice_path text;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS contract_link text;
ALTER TABLE evolvetogether_budget_entries ADD COLUMN IF NOT EXISTS ready_to_invoice boolean NOT NULL DEFAULT false;

-- Private bucket for attached invoice PDFs — this project doesn't have one
-- yet. Supabase → Storage → New bucket → name it exactly "invoices" → leave
-- "Public bucket" UNCHECKED (the bridge hands back short-lived signed URLs,
-- never a public link).

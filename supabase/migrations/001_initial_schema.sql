-- OPERON V1
-- 001_initial_schema.sql

create extension if not exists "pgcrypto";

-- =========================================================
-- 1. BUSINESSES
-- =========================================================

create table public.businesses (
    id uuid primary key default gen_random_uuid(),
    name text not null check (length(trim(name)) > 0),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- =========================================================
-- 2. USERS
-- =========================================================

create table public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    business_id uuid not null references public.businesses(id) on delete restrict,
    name text not null check (length(trim(name)) > 0),
    role text not null default 'operator'
        check (role in ('owner', 'admin', 'operator')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index users_business_id_idx
on public.users(business_id);

-- =========================================================
-- 3. CUSTOMERS
-- =========================================================

create table public.customers (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    name text not null check (length(trim(name)) > 0),
    email text,
    phone text,
    company_name text,
    notes text,
    status text not null default 'active'
        check (status in ('active', 'inactive', 'blocked')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index customers_business_id_idx
on public.customers(business_id);

create index customers_email_idx
on public.customers(email);

create index customers_phone_idx
on public.customers(phone);

-- =========================================================
-- 4. INVOICES
-- =========================================================

create table public.invoices (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    customer_id uuid not null references public.customers(id) on delete restrict,
    invoice_number text not null,
    amount numeric(14,2) not null check (amount > 0),
    currency text not null default 'INR',
    issue_date date not null,
    due_date date not null,
    status text not null default 'issued'
        check (
            status in (
                'draft',
                'issued',
                'partially_paid',
                'paid',
                'overdue',
                'cancelled'
            )
        ),
    notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint invoices_due_date_check
        check (due_date >= issue_date),

    constraint invoices_business_invoice_number_unique
        unique (business_id, invoice_number)
);

create index invoices_business_id_idx
on public.invoices(business_id);

create index invoices_customer_id_idx
on public.invoices(customer_id);

create index invoices_due_date_idx
on public.invoices(due_date);

create index invoices_status_idx
on public.invoices(status);

-- =========================================================
-- 5. PAYMENTS
-- =========================================================

create table public.payments (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    invoice_id uuid not null references public.invoices(id) on delete restrict,
    amount numeric(14,2) not null check (amount > 0),
    payment_date date not null,
    reference text,
    notes text,
    created_at timestamptz not null default now()
);

create index payments_business_id_idx
on public.payments(business_id);

create index payments_invoice_id_idx
on public.payments(invoice_id);

create index payments_payment_date_idx
on public.payments(payment_date);

-- =========================================================
-- 6. CONVERSATIONS
-- =========================================================

create table public.conversations (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    customer_id uuid not null references public.customers(id) on delete restrict,
    channel text not null
        check (channel in ('email', 'whatsapp', 'manual', 'other')),
    direction text not null
        check (direction in ('inbound', 'outbound')),
    message text not null,
    external_message_id text,
    created_at timestamptz not null default now()
);

create index conversations_business_id_idx
on public.conversations(business_id);

create index conversations_customer_id_idx
on public.conversations(customer_id);

create index conversations_created_at_idx
on public.conversations(created_at);

-- =========================================================
-- 7. FOLLOW UPS
-- =========================================================

create table public.follow_ups (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    customer_id uuid not null references public.customers(id) on delete restrict,
    invoice_id uuid references public.invoices(id) on delete restrict,
    channel text not null
        check (channel in ('email', 'whatsapp', 'manual')),
    subject text,
    message text not null,
    status text not null default 'draft'
        check (
            status in (
                'draft',
                'approved',
                'rejected',
                'scheduled',
                'sent',
                'cancelled'
            )
        ),
    scheduled_at timestamptz,
    approved_at timestamptz,
    approved_by uuid references public.users(id) on delete set null,
    sent_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index follow_ups_business_id_idx
on public.follow_ups(business_id);

create index follow_ups_customer_id_idx
on public.follow_ups(customer_id);

create index follow_ups_invoice_id_idx
on public.follow_ups(invoice_id);

create index follow_ups_status_idx
on public.follow_ups(status);

create index follow_ups_scheduled_at_idx
on public.follow_ups(scheduled_at);

-- =========================================================
-- 8. AI DECISIONS
-- =========================================================

create table public.ai_decisions (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    customer_id uuid references public.customers(id) on delete restrict,
    invoice_id uuid references public.invoices(id) on delete restrict,
    follow_up_id uuid references public.follow_ups(id) on delete restrict,
    provider text not null,
    model text not null,
    input_context jsonb not null,
    output jsonb not null,
    recommended_action text,
    priority text
        check (priority in ('low', 'medium', 'high', 'critical')),
    confidence numeric(5,4)
        check (confidence >= 0 and confidence <= 1),
    requires_human_review boolean not null default true,
    created_at timestamptz not null default now()
);

create index ai_decisions_business_id_idx
on public.ai_decisions(business_id);

create index ai_decisions_customer_id_idx
on public.ai_decisions(customer_id);

create index ai_decisions_invoice_id_idx
on public.ai_decisions(invoice_id);

create index ai_decisions_follow_up_id_idx
on public.ai_decisions(follow_up_id);

-- =========================================================
-- 9. NEXT ACTIONS
-- =========================================================

create table public.next_actions (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    customer_id uuid not null references public.customers(id) on delete restrict,
    invoice_id uuid references public.invoices(id) on delete restrict,
    ai_decision_id uuid references public.ai_decisions(id) on delete set null,
    action_type text not null
        check (
            action_type in (
                'review',
                'follow_up',
                'wait',
                'verify_payment',
                'resolve_dispute',
                'escalate',
                'close'
            )
        ),
    description text not null,
    status text not null default 'pending'
        check (
            status in (
                'pending',
                'in_progress',
                'completed',
                'cancelled'
            )
        ),
    due_at timestamptz,
    completed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index next_actions_business_id_idx
on public.next_actions(business_id);

create index next_actions_customer_id_idx
on public.next_actions(customer_id);

create index next_actions_status_idx
on public.next_actions(status);

create index next_actions_due_at_idx
on public.next_actions(due_at);

-- =========================================================
-- 10. ACTIVITY LOGS
-- =========================================================

create table public.activity_logs (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    user_id uuid references public.users(id) on delete set null,
    action text not null,
    entity_type text not null,
    entity_id uuid,
    metadata jsonb,
    created_at timestamptz not null default now()
);

create index activity_logs_business_id_idx
on public.activity_logs(business_id);

create index activity_logs_user_id_idx
on public.activity_logs(user_id);

create index activity_logs_entity_idx
on public.activity_logs(entity_type, entity_id);

create index activity_logs_created_at_idx
on public.activity_logs(created_at);

-- =========================================================
-- 11. AI PROVIDER CONFIGS
-- =========================================================

create table public.ai_provider_configs (
    id uuid primary key default gen_random_uuid(),
    business_id uuid not null references public.businesses(id) on delete restrict,
    provider text not null,
    model text not null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index ai_provider_configs_business_id_idx
on public.ai_provider_configs(business_id);

-- =========================================================
-- 12. UPDATED_AT TRIGGER
-- =========================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger businesses_updated_at
before update on public.businesses
for each row execute function public.set_updated_at();

create trigger users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

create trigger customers_updated_at
before update on public.customers
for each row execute function public.set_updated_at();

create trigger invoices_updated_at
before update on public.invoices
for each row execute function public.set_updated_at();

create trigger follow_ups_updated_at
before update on public.follow_ups
for each row execute function public.set_updated_at();

create trigger next_actions_updated_at
before update on public.next_actions
for each row execute function public.set_updated_at();

create trigger ai_provider_configs_updated_at
before update on public.ai_provider_configs
for each row execute function public.set_updated_at();

-- =========================================================
-- 13. HELPER FUNCTION FOR RLS
-- =========================================================

create or replace function public.current_business_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
    select business_id
    from public.users
    where id = auth.uid()
    limit 1;
$$;

revoke all on function public.current_business_id() from public;
grant execute on function public.current_business_id() to authenticated;

-- =========================================================
-- 14. ENABLE ROW LEVEL SECURITY
-- =========================================================

alter table public.businesses enable row level security;
alter table public.users enable row level security;
alter table public.customers enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;
alter table public.conversations enable row level security;
alter table public.follow_ups enable row level security;
alter table public.ai_decisions enable row level security;
alter table public.next_actions enable row level security;
alter table public.activity_logs enable row level security;
alter table public.ai_provider_configs enable row level security;

-- =========================================================
-- 15. RLS POLICIES
-- =========================================================

create policy "business members can view their business"
on public.businesses
for select
to authenticated
using (id = public.current_business_id());

create policy "business members can view users"
on public.users
for select
to authenticated
using (business_id = public.current_business_id());

create policy "business members can manage customers"
on public.customers
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can manage invoices"
on public.invoices
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can manage payments"
on public.payments
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can manage conversations"
on public.conversations
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can manage follow ups"
on public.follow_ups
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can view AI decisions"
on public.ai_decisions
for select
to authenticated
using (business_id = public.current_business_id());

create policy "business members can create AI decisions"
on public.ai_decisions
for insert
to authenticated
with check (business_id = public.current_business_id());

create policy "business members can manage next actions"
on public.next_actions
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

create policy "business members can view activity logs"
on public.activity_logs
for select
to authenticated
using (business_id = public.current_business_id());

create policy "business members can create activity logs"
on public.activity_logs
for insert
to authenticated
with check (business_id = public.current_business_id());

create policy "business members can manage AI configuration"
on public.ai_provider_configs
for all
to authenticated
using (business_id = public.current_business_id())
with check (business_id = public.current_business_id());

-- =========================================================
-- END OPERON V1 INITIAL SCHEMA
-- =========================================================

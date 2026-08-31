# OPERON V1 — DATABASE CONTRACT

## 1. Database

Database:
- PostgreSQL
- Hosted through Supabase

Primary requirements:
- Multi-tenant
- Business-level data isolation
- UUID primary keys
- UTC timestamps
- Exact numeric values for financial amounts
- Foreign-key integrity
- Row Level Security

---

## 2. Entity Relationship Overview

businesses
    │
    ├── users
    │
    └── customers
          │
          ├── invoices
          │     │
          │     └── payments
          │
          ├── conversations
          │
          └── follow_ups
                  │
                  └── ai_decisions
                         │
                         └── next_actions

All important entities
    │
    └── activity_logs

AI configuration belongs to:
    businesses

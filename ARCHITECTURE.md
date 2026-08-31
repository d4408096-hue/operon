# OPERON V1 — ARCHITECTURE CONTRACT

## 1. Product

Operon is a configurable Digital Receivables Employee for businesses.

Its purpose is to help a business monitor receivables, identify overdue invoices, analyze customer/payment context, recommend follow-up actions, generate communication drafts, understand customer responses, and recommend the next action.

V1 is an MVP. Reliability, simplicity, traceability, and human control are more important than maximum automation.

---

## 2. V1 Core Workflow

Customer
→ Invoice
→ Receivables Analysis
→ Priority
→ AI Analysis
→ Recommended Action
→ Follow-up Draft
→ Human Review
→ Approval/Rejection
→ Customer Response
→ Response Classification
→ Next Action
→ Activity/Audit Log

---

## 3. Technology Stack

Frontend:
- Next.js
- TypeScript
- Tailwind CSS
- App Router

Backend:
- Next.js server-side functionality/API routes where appropriate
- Supabase

Database:
- PostgreSQL through Supabase

AI:
- Provider-independent AI adapter
- Nemotron is the initial development/testing provider
- Customer-owned API credentials will be used in the final deployment

Version control:
- Git
- GitHub

Development environment:
- GitHub Codespaces
- Android browser/device

---

## 4. Architecture Principles

1. Keep V1 simple.
2. Prefer deterministic code for calculations and business rules.
3. Use AI for interpretation, classification, reasoning, and communication generation.
4. AI must not be the source of truth for financial data.
5. Frontend must never expose private API keys.
6. AI provider must be replaceable.
7. Important external actions require human approval in V1.
8. Important AI decisions must be logged.
9. Customer data must be isolated between businesses.
10. Every module must have clear inputs and outputs.
11. Avoid unnecessary third-party dependencies.
12. Do not add features outside V1 scope without explicit approval.

---

## 5. Core Entities

V1 contains these primary entities:

- Business
- User
- Customer
- Invoice
- Payment
- FollowUp
- Conversation
- AI Decision
- Next Action
- Activity Log
- AI Provider Configuration

---

## 6. Business

A Business represents the customer organization using Operon.

Required concepts:

- id
- name
- created_at
- updated_at

Every business-owned record must be associated with a Business.

No business may access another business's records.

---

## 7. User

A User represents a person authorized to operate Operon for a Business.

Authentication should use Supabase Auth.

Required concepts:

- id
- business_id
- name
- role
- created_at
- updated_at

Initial roles:

- owner
- admin
- operator

V1 permissions should remain simple.

---

## 8. Customer

A Customer represents a business/customer who owes money to the Operon user's business.

Required concepts:

- id
- business_id
- name
- email
- phone
- company_name
- notes
- status
- created_at
- updated_at

Customer status examples:

- active
- inactive
- blocked

---

## 9. Invoice

An Invoice represents money owed by a Customer.

Required concepts:

- id
- business_id
- customer_id
- invoice_number
- amount
- currency
- issue_date
- due_date
- status
- notes
- created_at
- updated_at

Invoice status examples:

- draft
- issued
- partially_paid
- paid
- overdue
- cancelled

Financial values must be stored using appropriate exact numeric/database types rather than floating-point calculations.

---

## 10. Payment

A Payment represents money received against an invoice.

Required concepts:

- id
- business_id
- invoice_id
- amount
- payment_date
- reference
- notes
- created_at

Payment records must not be invented by AI.

---

## 11. Receivables Engine

The Receivables Engine is deterministic.

It should calculate:

- outstanding amount
- days until due
- days overdue
- payment status
- aging category
- basic priority score

AI should not calculate fundamental financial truth when normal code can calculate it reliably.

Example:

Invoice due date:
2026-09-01

Current date:
2026-09-18

Result:

17 days overdue

---

## 12. Priority Engine

The priority engine combines deterministic business information.

Possible factors:

- days overdue
- outstanding amount
- customer payment history
- previous follow-ups
- previous promises
- dispute status

V1 should produce a priority such as:

- low
- medium
- high
- critical

The exact scoring algorithm should remain configurable and documented.

---

## 13. AI Provider Abstraction

All AI requests must pass through a provider abstraction.

Architecture:

Operon
→ AI Service
→ AI Provider Adapter
→ Provider API

Initial provider:

Nemotron

The application must not hard-code business logic directly to one AI provider.

Future providers can be added without rewriting the decision engine.

---

## 14. AI Configuration

AI credentials must be stored securely on the server.

Never expose private API keys in:

- frontend source
- browser storage
- Git repository
- public API responses
- client-side JavaScript

Development may use environment variables.

Production/customer deployments should use customer-owned credentials.

---

## 15. AI Responsibilities

AI may be used for:

- customer context analysis
- payment-behavior interpretation
- follow-up recommendation
- communication generation
- customer-response classification
- intent detection
- next-action recommendation

AI must not independently invent:

- invoice amounts
- payment records
- customer identity
- payment status
- financial transactions

---

## 16. Decision Engine

The Decision Engine receives structured business data and produces a structured recommendation.

Input may include:

- customer information
- invoice information
- outstanding amount
- overdue days
- payment history
- previous conversations
- previous follow-ups
- business rules

Output should contain structured fields such as:

- recommended_action
- reason
- priority
- confidence
- requires_human_review

The AI output must be validated before being used by the application.

---

## 17. Follow-Up Engine

The Follow-Up Engine generates a communication draft based on structured context.

Possible channels:

- email
- WhatsApp
- manual copy/send

V1 should prioritize generating a draft.

Automatic external sending is not required for the initial MVP.

The generated message should be editable before approval.

---

## 18. Response Understanding

The Response Understanding module classifies customer responses.

Initial categories:

- payment_completed
- payment_promised
- payment_delay
- dispute
- question
- negotiation
- refusal
- unclear
- human_required

The system should preserve the original response.

AI classification must not automatically modify financial records without appropriate validation.

---

## 19. Next Action Engine

The Next Action Engine determines the recommended next step.

Examples:

Payment completed
→ mark follow-up workflow complete

Payment promised
→ schedule check on promised date

Payment delay
→ recommend follow-up

Dispute
→ escalate to human

Unclear response
→ human review

The system should avoid infinite automatic follow-up loops.

---

## 20. Human Approval

V1 requires human approval before consequential external communication.

Actions:

- approve
- edit
- reject

The system should record:

- original AI recommendation
- edited content
- approving user
- timestamp
- final action

---

## 21. Activity / Audit Log

Important system actions must be logged.

Examples:

- customer created
- invoice created
- invoice updated
- payment recorded
- AI analysis generated
- follow-up generated
- message edited
- action approved
- action rejected
- response classified
- next action created

Each activity should contain enough information to understand:

WHAT happened
WHEN it happened
WHO initiated/approved it
WHAT entity was affected

---

## 22. Security

V1 must implement:

- Supabase authentication
- business-level data isolation
- Row Level Security where appropriate
- server-side handling of secrets
- input validation
- authorization checks
- no secrets in Git
- no cross-business data access

Security must not be postponed until after customer data is introduced.

---

## 23. API / Service Boundaries

The frontend should communicate with defined application services rather than directly implementing business logic everywhere.

Conceptual services:

- customer service
- invoice service
- payment service
- receivables service
- AI service
- decision service
- follow-up service
- conversation service
- next-action service
- audit service

Services should have clear typed inputs and outputs.

---

## 24. Testing Strategy

Each module must be tested independently.

The full workflow must also be tested end-to-end.

Required scenarios include:

1. Normal unpaid invoice
2. Recently overdue invoice
3. Severely overdue invoice
4. High-value overdue invoice
5. Paid invoice
6. Partially paid invoice
7. Customer promises payment
8. Customer disputes invoice
9. Customer asks a question
10. Unclear customer response
11. AI failure
12. Invalid AI response
13. Missing customer data
14. Unauthorized access attempt
15. Cross-business data access attempt

---

## 25. V1 Scope

IN SCOPE:

- authentication
- business/user structure
- customer management
- invoice management
- payment records
- overdue calculation
- priority
- AI analysis
- follow-up generation
- response classification
- next-action recommendation
- human approval
- audit/activity history

OUT OF SCOPE FOR INITIAL MVP:

- autonomous financial transactions
- automatic payment collection
- automatic payment verification
- advanced accounting integrations
- complex WhatsApp automation
- complex email automation
- mobile native application
- multi-agent architecture
- advanced analytics
- enterprise billing
- marketplace
- multiple digital employees

---

## 26. Development Method

Build modules incrementally.

For every module:

1. Read this architecture contract.
2. Implement only the assigned module.
3. Follow existing interfaces.
4. Do not redesign unrelated modules.
5. Test the module.
6. Fix errors.
7. Commit working code.
8. Only then continue to the next module.

AI-generated code must be reviewed and tested before integration.

---

## 27. Customer Handover Model

Operon is supplied as a digital employee/infrastructure.

Customer is responsible for:

- their business data
- their hosting/infrastructure where applicable
- their AI provider/API usage
- third-party messaging providers
- ongoing operational costs
- business decisions
- use of generated communications

Before customer handover:

- remove developer API credentials
- remove test data
- remove development secrets
- verify environment configuration
- verify customer-specific data isolation

---

## 28. Definition of Done — V1

V1 is considered functionally complete when:

A business can create a customer.

A business can create an invoice.

Operon can determine whether the invoice is overdue.

Operon can calculate outstanding information and priority.

Operon can send structured context to the configured AI provider.

AI can analyze the situation and recommend an action.

Operon can generate a follow-up draft.

A human can review and approve/edit/reject it.

A customer response can be classified.

Operon can recommend the next action.

Important actions appear in the activity/audit history.

Unauthorized users cannot access another business's data.

The complete workflow can be demonstrated repeatedly using test data.

---

## 29. Architecture Rule

Simplicity is preferred.

Do not introduce additional frameworks, services, agents, databases, queues, microservices, or integrations unless they are necessary for V1.

The goal is a reliable working digital employee, not maximum technical complexity.

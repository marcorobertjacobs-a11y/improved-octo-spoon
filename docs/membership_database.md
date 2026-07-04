# Membership Database

This repository includes a SQLite membership database schema that can track members, addresses, membership levels, membership terms, payments, and emergency contacts.

## Files

- `database/membership_schema.sql` creates the database tables, indexes, update timestamp triggers, and an `active_member_roster` view.
- `database/seed_membership_data.sql` loads example membership levels, members, memberships, payments, addresses, and emergency contacts.

## Create a local database

```bash
./scripts/create_membership_db.sh membership.db
```

Or run the SQL files manually:

```bash
sqlite3 membership.db < database/membership_schema.sql
sqlite3 membership.db < database/seed_membership_data.sql
```

## Example queries

List active members:

```sql
SELECT * FROM active_member_roster ORDER BY last_name, first_name;
```

Find payment history for a member:

```sql
SELECT
    m.member_number,
    m.first_name || ' ' || m.last_name AS member_name,
    p.amount_cents / 100.0 AS amount,
    p.currency,
    p.paid_on,
    p.payment_method,
    p.status
FROM payments p
JOIN memberships ms ON ms.id = p.membership_id
JOIN members m ON m.id = ms.member_id
WHERE m.member_number = 'M-0001'
ORDER BY p.paid_on DESC;
```

## Design notes

- Monetary values are stored as integer cents to avoid floating-point rounding errors.
- Foreign keys are declared with cascading deletes for member-owned data and restricted deletes for membership levels currently in use.
- Status columns use `CHECK` constraints to keep lifecycle values consistent.
- Date columns use ISO-8601 `YYYY-MM-DD` text values for SQLite compatibility.

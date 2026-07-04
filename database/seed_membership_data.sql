PRAGMA foreign_keys = ON;

INSERT INTO membership_levels (id, name, description, monthly_fee_cents, billing_interval) VALUES
    (1, 'Basic', 'Standard member access.', 2500, 'monthly'),
    (2, 'Family', 'Membership for a household.', 4500, 'monthly'),
    (3, 'Lifetime', 'One-time lifetime membership.', 0, 'annual')
ON CONFLICT(id) DO UPDATE SET
    name = excluded.name,
    description = excluded.description,
    monthly_fee_cents = excluded.monthly_fee_cents,
    billing_interval = excluded.billing_interval;

INSERT INTO members (id, member_number, first_name, last_name, email, phone, date_of_birth, joined_on, status) VALUES
    (1, 'M-0001', 'Avery', 'Johnson', 'avery.johnson@example.com', '555-0101', '1990-04-12', '2026-01-15', 'active'),
    (2, 'M-0002', 'Sam', 'Rivera', 'sam.rivera@example.com', '555-0102', '1984-09-03', '2026-02-01', 'active'),
    (3, 'M-0003', 'Jordan', 'Lee', 'jordan.lee@example.com', '555-0103', NULL, '2026-03-20', 'inactive')
ON CONFLICT(id) DO UPDATE SET
    member_number = excluded.member_number,
    first_name = excluded.first_name,
    last_name = excluded.last_name,
    email = excluded.email,
    phone = excluded.phone,
    date_of_birth = excluded.date_of_birth,
    joined_on = excluded.joined_on,
    status = excluded.status;

INSERT INTO member_addresses (id, member_id, address_type, line1, city, region, postal_code, country, is_primary) VALUES
    (1, 1, 'home', '100 Main St', 'Springfield', 'IL', '62701', 'US', 1),
    (2, 2, 'home', '200 Oak Ave', 'Madison', 'WI', '53703', 'US', 1),
    (3, 3, 'mailing', '300 Pine Rd', 'Austin', 'TX', '78701', 'US', 1)
ON CONFLICT(id) DO UPDATE SET
    member_id = excluded.member_id,
    address_type = excluded.address_type,
    line1 = excluded.line1,
    city = excluded.city,
    region = excluded.region,
    postal_code = excluded.postal_code,
    country = excluded.country,
    is_primary = excluded.is_primary;

INSERT INTO memberships (id, member_id, level_id, starts_on, ends_on, auto_renew, status) VALUES
    (1, 1, 1, '2026-01-15', NULL, 1, 'active'),
    (2, 2, 2, '2026-02-01', NULL, 1, 'active'),
    (3, 3, 1, '2026-03-20', '2026-06-20', 0, 'expired')
ON CONFLICT(id) DO UPDATE SET
    member_id = excluded.member_id,
    level_id = excluded.level_id,
    starts_on = excluded.starts_on,
    ends_on = excluded.ends_on,
    auto_renew = excluded.auto_renew,
    status = excluded.status;

INSERT INTO payments (id, membership_id, amount_cents, currency, paid_on, payment_method, reference_number, status) VALUES
    (1, 1, 2500, 'USD', '2026-01-15', 'credit_card', 'PAY-0001', 'completed'),
    (2, 2, 4500, 'USD', '2026-02-01', 'bank_transfer', 'PAY-0002', 'completed')
ON CONFLICT(id) DO UPDATE SET
    membership_id = excluded.membership_id,
    amount_cents = excluded.amount_cents,
    currency = excluded.currency,
    paid_on = excluded.paid_on,
    payment_method = excluded.payment_method,
    reference_number = excluded.reference_number,
    status = excluded.status;

INSERT INTO member_emergency_contacts (id, member_id, name, relationship, phone, email, is_primary) VALUES
    (1, 1, 'Morgan Johnson', 'Sibling', '555-1101', 'morgan.johnson@example.com', 1),
    (2, 2, 'Casey Rivera', 'Spouse', '555-1102', 'casey.rivera@example.com', 1)
ON CONFLICT(id) DO UPDATE SET
    member_id = excluded.member_id,
    name = excluded.name,
    relationship = excluded.relationship,
    phone = excluded.phone,
    email = excluded.email,
    is_primary = excluded.is_primary;

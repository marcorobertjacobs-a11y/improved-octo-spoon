-- Membership database schema for SQLite.
-- Enable foreign key checks for every connection before using this database.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS membership_levels (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    monthly_fee_cents INTEGER NOT NULL CHECK (monthly_fee_cents >= 0),
    billing_interval TEXT NOT NULL DEFAULT 'monthly'
        CHECK (billing_interval IN ('monthly', 'quarterly', 'annual')),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS members (
    id INTEGER PRIMARY KEY,
    member_number TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    date_of_birth TEXT CHECK (date_of_birth IS NULL OR date(date_of_birth) = date_of_birth),
    joined_on TEXT NOT NULL DEFAULT (date('now')) CHECK (date(joined_on) = joined_on),
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'suspended', 'cancelled')),
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS member_addresses (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    address_type TEXT NOT NULL DEFAULT 'home'
        CHECK (address_type IN ('home', 'work', 'billing', 'mailing', 'other')),
    line1 TEXT NOT NULL,
    line2 TEXT,
    city TEXT NOT NULL,
    region TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'US',
    is_primary INTEGER NOT NULL DEFAULT 1 CHECK (is_primary IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS memberships (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    level_id INTEGER NOT NULL,
    starts_on TEXT NOT NULL CHECK (date(starts_on) = starts_on),
    ends_on TEXT CHECK (ends_on IS NULL OR date(ends_on) = ends_on),
    auto_renew INTEGER NOT NULL DEFAULT 1 CHECK (auto_renew IN (0, 1)),
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'expired', 'paused', 'cancelled')),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    CHECK (ends_on IS NULL OR ends_on >= starts_on),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (level_id) REFERENCES membership_levels(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY,
    membership_id INTEGER NOT NULL,
    amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
    currency TEXT NOT NULL DEFAULT 'USD' CHECK (length(currency) = 3),
    paid_on TEXT NOT NULL DEFAULT (date('now')) CHECK (date(paid_on) = paid_on),
    payment_method TEXT NOT NULL
        CHECK (payment_method IN ('cash', 'check', 'credit_card', 'debit_card', 'bank_transfer', 'other')),
    reference_number TEXT UNIQUE,
    status TEXT NOT NULL DEFAULT 'completed'
        CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (membership_id) REFERENCES memberships(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS member_emergency_contacts (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    relationship TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    is_primary INTEGER NOT NULL DEFAULT 1 CHECK (is_primary IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_members_status ON members(status);
CREATE INDEX IF NOT EXISTS idx_memberships_member ON memberships(member_id);
CREATE INDEX IF NOT EXISTS idx_memberships_status_dates ON memberships(status, starts_on, ends_on);
CREATE INDEX IF NOT EXISTS idx_payments_membership ON payments(membership_id);

CREATE TRIGGER IF NOT EXISTS trg_members_updated_at
AFTER UPDATE ON members
FOR EACH ROW
BEGIN
    UPDATE members SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS trg_memberships_updated_at
AFTER UPDATE ON memberships
FOR EACH ROW
BEGIN
    UPDATE memberships SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE VIEW IF NOT EXISTS active_member_roster AS
SELECT
    m.id AS member_id,
    m.member_number,
    m.first_name,
    m.last_name,
    m.email,
    m.phone,
    ml.name AS membership_level,
    ms.starts_on,
    ms.ends_on,
    ms.auto_renew
FROM members m
JOIN memberships ms ON ms.member_id = m.id
JOIN membership_levels ml ON ml.id = ms.level_id
WHERE m.status = 'active'
  AND ms.status = 'active'
  AND (ms.ends_on IS NULL OR ms.ends_on >= date('now'));

-- Drop Project Tables
DROP TABLE GS_users cascade constraints;
DROP TABLE GS_organizations cascade constraints;
DROP TABLE GS_needs cascade constraints;
DROP TABLE GS_donations cascade constraints;
DROP TABLE GS_matches cascade constraints;
DROP TABLE GS_auditoria cascade constraints;

-- Drop Project sequences
DROP SEQUENCE seq_users;
DROP SEQUENCE seq_organizations;
DROP SEQUENCE seq_needs;
DROP SEQUENCE seq_donations;
DROP SEQUENCE seq_matches;
DROP SEQUENCE seq_auditoria;

-- Create Project Sequences
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_organizations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_needs START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_matches START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_auditoria START WITH 1 INCREMENT BY 1;

-- Create Project Tables
CREATE TABLE GS_organizations (
    id                  NUMBER DEFAULT seq_organizations.NEXTVAL PRIMARY KEY,
    name                VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR2(255) NOT NULL,
    contact_email       VARCHAR2(255),
    contact_phone       VARCHAR2(20),
    type                VARCHAR2(20), -- NGO, CHARITY, GOVERNMENT, RELIGIOUS, COMMUNITY
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP
);

CREATE TABLE GS_users (
    id                  NUMBER DEFAULT seq_users.NEXTVAL PRIMARY KEY,
    email               VARCHAR2(255) UNIQUE NOT NULL,
    phone               VARCHAR2(20),
    name                VARCHAR2(255) NOT NULL,
    password_hash       VARCHAR2(255),
    role                VARCHAR2(20), -- DONOR, NGO_MENBER, ADMIN 
    is_active           CHAR(1) DEFAULT 'Y',
    last_login          TIMESTAMP,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP,
    organization_id     NUMBER,
    FOREIGN KEY (organization_id) REFERENCES GS_organizations(id),
    CONSTRAINT chk_users_role CHECK (role IN ('DONOR', 'NGO_MEMBER', 'ADMIN')),
    CONSTRAINT chk_users_active CHECK (is_active IN ('Y', 'N'))
);

CREATE TABLE GS_needs(
    id                  NUMBER DEFAULT seq_needs.NEXTVAL PRIMARY KEY,
    title               VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR2(255) NOT NULL,
    category            VARCHAR2(20), -- FOOD, WATER, CLOTHING, MEDICAL, SHELTER, EDUCATION, TRANSPORTATION, OTHER
    priority            VARCHAR2(10), -- LOW, MEDIUM, HIGH, CRITICAL
    status              VARCHAR2(20), -- ACTIVE, PARTIALLY_FULFILLED, FULFILLED, EXPIRED, CANCELLED
    quantity            NUMBER NOT NULL,
    unit                VARCHAR(50),
    deadline_date       TIMESTAMP,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP,
    creator_id          NUMBER NOT NULL,
    organization_id     NUMBER,
    FOREIGN KEY (creator_id) REFERENCES GS_users(id),
    FOREIGN KEY (organization_id) REFERENCES GS_organizations(id),
    CONSTRAINT chk_needs_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_needs_status CHECK (status IN ('ACTIVE', 'PARTIALLY_FULFILLED', 'FULFILLED', 'EXPIRED', 'CANCELLED')),
    CONSTRAINT chk_needs_quantity CHECK (quantity > 0)
);

CREATE TABLE GS_donations(
    id                  NUMBER DEFAULT seq_donations.NEXTVAL PRIMARY KEY,
    title               VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR(255) NOT NULL,
    category            VARCHAR2(20),
    status              VARCHAR2(20) DEFAULT 'AVAILABLE',
    quantity            NUMBER NOT NULL,
    unit                VARCHAR2(50),
    expiry_date        TIMESTAMP,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    donor_id            NUMBER NOT NULL,
    FOREIGN KEY (donor_id) REFERENCES GS_users(id),
    CONSTRAINT chk_donations_status CHECK (status IN ('AVAILABLE', 'RESERVED', 'DONATED', 'EXPIRED')),
    CONSTRAINT chk_donations_quantity CHECK (quantity > 0)
);

CREATE TABLE GS_matches(
    id                  NUMBER DEFAULT seq_matches.NEXTVAL PRIMARY KEY,
    need_id             NUMBER NOT NULL,
    donation_id         NUMBER NOT NULL,
    status              VARCHAR(20), -- PENDING, CONFIRMED, COMPLETED, REJECTED, CANCELLED
    matched_quantity    NUMBER,
    compatibility_score NUMBER(3,2), -- Decimal 0.00 - 1.00
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    confirmed_at        TIMESTAMP,
    notes               CLOB,
    FOREIGN KEY (need_id) REFERENCES GS_needs(id),
    FOREIGN KEY (donation_id) REFERENCES GS_donations(id),
    CONSTRAINT chk_matches_status CHECK (status IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT chk_matches_quantity CHECK (matched_quantity > 0),
    CONSTRAINT chk_compatibility_score CHECK (compatibility_score BETWEEN 0 AND 1)
);

CREATE TABLE GS_auditoria(
    id                  NUMBER DEFAULT seq_auditoria.NEXTVAL PRIMARY KEY,
    table_name          VARCHAR2(50) NOT NULL,
    register_id         NUMBER NOT NULL,
    operation_type      VARCHAR(10) NOT NULL,
    date_time           TIMESTAMP NOT NULL,
    db_user             VARCHAR2(50) NOT NULL,
    old_data            CLOB,
    new_data            CLOB,
    CONSTRAINT chk_auditoria_opration_type CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE'))
);
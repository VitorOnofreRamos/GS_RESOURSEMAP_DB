-- Insert 5 rows into GS_organizations
INSERT INTO GS_organizations (name, description, location, contact_email, contact_phone, type, created_at)
VALUES ('Hope Foundation', 'Provides aid to underprivileged communities.', 'New York, NY', 'contact@hope.org', '555-1111', 'NGO', SYSTIMESTAMP);

INSERT INTO GS_organizations (name, description, location, contact_email, contact_phone, type, created_at)
VALUES ('City Food Bank', 'Distributes food to people in need.', 'Chicago, IL', 'info@cityfoodbank.org', '555-2222', 'CHARITY', SYSTIMESTAMP);

INSERT INTO GS_organizations (name, description, location, contact_email, contact_phone, type, created_at)
VALUES ('Water for All', 'Focus on clean water supplies.', 'Los Angeles, CA', 'water@forall.org', '555-3333', 'NGO', SYSTIMESTAMP);

INSERT INTO GS_organizations (name, description, location, contact_email, contact_phone, type, created_at)
VALUES ('Saint Mary Church', 'Community and religious support.', 'Houston, TX', 'stmary@church.org', '555-4444', 'RELIGIOUS', SYSTIMESTAMP);

INSERT INTO GS_organizations (name, description, location, contact_email, contact_phone, type, created_at)
VALUES ('Shelter United', 'Shelter and housing for the homeless.', 'Miami, FL', 'contact@shelterunited.org', '555-5555', 'COMMUNITY', SYSTIMESTAMP);

-- Insert 5 rows into GS_users (assume ids 1-5 for organizations)
INSERT INTO GS_users (email, phone, name, password_hash, role, is_active, last_login, created_at, organization_id)
VALUES ('alice@hope.org', '555-1010', 'Alice Smith', 'hash1', 'NGO_MEMBER', 'Y', SYSTIMESTAMP, SYSTIMESTAMP, 1);

INSERT INTO GS_users (email, phone, name, password_hash, role, is_active, last_login, created_at, organization_id)
VALUES ('bob@cityfoodbank.org', '555-2020', 'Bob Johnson', 'hash2', 'NGO_MEMBER', 'Y', SYSTIMESTAMP, SYSTIMESTAMP, 2);

INSERT INTO GS_users (email, phone, name, password_hash, role, is_active, last_login, created_at, organization_id)
VALUES ('carol@waterforall.org', '555-3030', 'Carol Lee', 'hash3', 'NGO_MEMBER', 'Y', SYSTIMESTAMP, SYSTIMESTAMP, 3);

INSERT INTO GS_users (email, phone, name, password_hash, role, is_active, last_login, created_at, organization_id)
VALUES ('eve@shelterunited.org', '555-4040', 'Eve Davis', 'hash4', 'NGO_MEMBER', 'Y', SYSTIMESTAMP, SYSTIMESTAMP, 5);

INSERT INTO GS_users (email, phone, name, password_hash, role, is_active, last_login, created_at, organization_id)
VALUES ('daniel@gmail.com', '555-5050', 'Daniel Brown', 'hash5', 'DONOR', 'Y', SYSTIMESTAMP, SYSTIMESTAMP, NULL);

-- Insert 5 rows into GS_needs (use users 1-4 and orgs 1-5)
INSERT INTO GS_needs (title, description, location, category, priority, status, quantity, unit, deadline_date, created_at, creator_id, organization_id)
VALUES ('Canned Food', 'Need canned food for 100 families.', 'New York, NY', 'FOOD', 'HIGH', 'ACTIVE', 500, 'cans', SYSTIMESTAMP+7, SYSTIMESTAMP, 1, 1);

INSERT INTO GS_needs (title, description, location, category, priority, status, quantity, unit, deadline_date, created_at, creator_id, organization_id)
VALUES ('Bottled Water', 'Clean bottled water for distribution.', 'Los Angeles, CA', 'WATER', 'CRITICAL', 'ACTIVE', 1000, 'liters', SYSTIMESTAMP+5, SYSTIMESTAMP, 3, 3);

INSERT INTO GS_needs (title, description, location, category, priority, status, quantity, unit, deadline_date, created_at, creator_id, organization_id)
VALUES ('Blankets', 'Warm blankets for winter.', 'Chicago, IL', 'CLOTHING', 'MEDIUM', 'ACTIVE', 200, 'blankets', SYSTIMESTAMP+15, SYSTIMESTAMP, 2, 2);

INSERT INTO GS_needs (title, description, location, category, priority, status, quantity, unit, deadline_date, created_at, creator_id, organization_id)
VALUES ('Medical Kits', 'Basic medical kits for families.', 'Miami, FL', 'MEDICAL', 'HIGH', 'ACTIVE', 150, 'kits', SYSTIMESTAMP+10, SYSTIMESTAMP, 4, 5);

INSERT INTO GS_needs (title, description, location, category, priority, status, quantity, unit, deadline_date, created_at, creator_id, organization_id)
VALUES ('School Supplies', 'Notebooks and pens for students.', 'Houston, TX', 'EDUCATION', 'LOW', 'ACTIVE', 300, 'packs', SYSTIMESTAMP+20, SYSTIMESTAMP, 1, 4);

-- Insert 5 rows into GS_donations (donor_id = 5)
INSERT INTO GS_donations (title, description, location, category, status, quantity, unit, expiry_date, created_at, donor_id)
VALUES ('Boxed Meals', 'Individually packaged meals.', 'New York, NY', 'FOOD', 'AVAILABLE', 250, 'boxes', SYSTIMESTAMP+3, SYSTIMESTAMP, 5);

INSERT INTO GS_donations (title, description, location, category, status, quantity, unit, expiry_date, created_at, donor_id)
VALUES ('Bottled Water', 'Mineral water bottles.', 'Los Angeles, CA', 'WATER', 'AVAILABLE', 600, 'bottles', SYSTIMESTAMP+5, SYSTIMESTAMP, 5);

INSERT INTO GS_donations (title, description, location, category, status, quantity, unit, expiry_date, created_at, donor_id)
VALUES ('Winter Blankets', 'Thick blankets for cold weather.', 'Chicago, IL', 'CLOTHING', 'AVAILABLE', 150, 'blankets', SYSTIMESTAMP+7, SYSTIMESTAMP, 5);

INSERT INTO GS_donations (title, description, location, category, status, quantity, unit, expiry_date, created_at, donor_id)
VALUES ('First Aid Kits', 'Complete first aid kits.', 'Miami, FL', 'MEDICAL', 'AVAILABLE', 100, 'kits', SYSTIMESTAMP+10, SYSTIMESTAMP, 5);

INSERT INTO GS_donations (title, description, location, category, status, quantity, unit, expiry_date, created_at, donor_id)
VALUES ('School Bags', 'Bags for students.', 'Houston, TX', 'EDUCATION', 'AVAILABLE', 120, 'bags', SYSTIMESTAMP+8, SYSTIMESTAMP, 5);

-- Insert 5 rows into GS_matches (linking needs and donations, use IDs above)
INSERT INTO GS_matches (need_id, donation_id, status, matched_quantity, compatibility_score, created_at, confirmed_at, notes)
VALUES (1, 1, 'CONFIRMED', 200, 0.92, SYSTIMESTAMP, SYSTIMESTAMP, 'Food matched for Hope Foundation');

INSERT INTO GS_matches (need_id, donation_id, status, matched_quantity, compatibility_score, created_at, confirmed_at, notes)
VALUES (2, 2, 'CONFIRMED', 500, 0.95, SYSTIMESTAMP, SYSTIMESTAMP, 'Water matched for Water for All');

INSERT INTO GS_matches (need_id, donation_id, status, matched_quantity, compatibility_score, created_at, confirmed_at, notes)
VALUES (3, 3, 'CONFIRMED', 120, 0.88, SYSTIMESTAMP, SYSTIMESTAMP, 'Blankets matched for City Food Bank');

INSERT INTO GS_matches (need_id, donation_id, status, matched_quantity, compatibility_score, created_at, confirmed_at, notes)
VALUES (4, 4, 'CONFIRMED', 80, 0.93, SYSTIMESTAMP, SYSTIMESTAMP, 'Medical kits matched for Shelter United');

INSERT INTO GS_matches (need_id, donation_id, status, matched_quantity, compatibility_score, created_at, confirmed_at, notes)
VALUES (5, 5, 'CONFIRMED', 100, 0.85, SYSTIMESTAMP, SYSTIMESTAMP, 'School supplies matched for Saint Mary Church');

-- Selects
Select * from GS_users;
Select * from GS_organizations;
Select * from GS_needs;
Select * from GS_donations;
Select * from GS_matches;
Select * from GS_auditoria;
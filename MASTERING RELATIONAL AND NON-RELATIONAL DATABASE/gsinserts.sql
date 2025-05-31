-- =====================================================
-- INSERTS COM PROCEDURES
-- =====================================================

-- Inserir 5 organizações usando INSERT_ORGANIZATION
BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'Hope Foundation',
        p_description => 'Provides aid to underprivileged communities.',
        p_location => 'New York, NY',
        p_contact_email => 'contact@hope.org',
        p_contact_phone => '555-1111',
        p_type => 'NGO'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'City Food Bank',
        p_description => 'Distributes food to people in need.',
        p_location => 'Chicago, IL',
        p_contact_email => 'info@cityfoodbank.org',
        p_contact_phone => '555-2222',
        p_type => 'CHARITY'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'Water for All',
        p_description => 'Focus on clean water supplies.',
        p_location => 'Los Angeles, CA',
        p_contact_email => 'water@forall.org',
        p_contact_phone => '555-3333',
        p_type => 'NGO'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'Saint Mary Church',
        p_description => 'Community and religious support.',
        p_location => 'Houston, TX',
        p_contact_email => 'stmary@church.org',
        p_contact_phone => '555-4444',
        p_type => 'RELIGIOUS'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'Shelter United',
        p_description => 'Shelter and housing for the homeless.',
        p_location => 'Miami, FL',
        p_contact_email => 'contact@shelterunited.org',
        p_contact_phone => '555-5555',
        p_type => 'COMMUNITY'
    );
END;
/

-- Inserir 5 usuários usando INSERT_USER
BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'alice@hope.org',
        p_phone => '555-1010',
        p_name => 'Alice Smith',
        p_password_hash => 'hash1',
        p_role => 'NGO_MEMBER',
        p_is_active => 'Y',
        p_organization_id => 1
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'bob@cityfoodbank.org',
        p_phone => '555-2020',
        p_name => 'Bob Johnson',
        p_password_hash => 'hash2',
        p_role => 'NGO_MEMBER',
        p_is_active => 'Y',
        p_organization_id => 2
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'carol@waterforall.org',
        p_phone => '555-3030',
        p_name => 'Carol Lee',
        p_password_hash => 'hash3',
        p_role => 'NGO_MEMBER',
        p_is_active => 'Y',
        p_organization_id => 3
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'eve@shelterunited.org',
        p_phone => '555-4040',
        p_name => 'Eve Davis',
        p_password_hash => 'hash4',
        p_role => 'NGO_MEMBER',
        p_is_active => 'Y',
        p_organization_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'daniel@gmail.com',
        p_phone => '555-5050',
        p_name => 'Daniel Brown',
        p_password_hash => 'hash5',
        p_role => 'DONOR',
        p_is_active => 'Y',
        p_organization_id => NULL
    );
END;
/

-- Inserir 5 necessidades usando INSERT_NEED
BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'Canned Food',
        p_description => 'Need canned food for 100 families.',
        p_location => 'New York, NY',
        p_category => 'FOOD',
        p_priority => 'HIGH',
        p_status => 'ACTIVE',
        p_quantity => 500,
        p_unit => 'cans',
        p_deadline_date => SYSTIMESTAMP + 7,
        p_creator_id => 1,
        p_organization_id => 1
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'Bottled Water',
        p_description => 'Clean bottled water for distribution.',
        p_location => 'Los Angeles, CA',
        p_category => 'WATER',
        p_priority => 'CRITICAL',
        p_status => 'ACTIVE',
        p_quantity => 1000,
        p_unit => 'liters',
        p_deadline_date => SYSTIMESTAMP + 5,
        p_creator_id => 3,
        p_organization_id => 3
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'Blankets',
        p_description => 'Warm blankets for winter.',
        p_location => 'Chicago, IL',
        p_category => 'CLOTHING',
        p_priority => 'MEDIUM',
        p_status => 'ACTIVE',
        p_quantity => 200,
        p_unit => 'blankets',
        p_deadline_date => SYSTIMESTAMP + 15,
        p_creator_id => 2,
        p_organization_id => 2
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'Medical Kits',
        p_description => 'Basic medical kits for families.',
        p_location => 'Miami, FL',
        p_category => 'MEDICAL',
        p_priority => 'HIGH',
        p_status => 'ACTIVE',
        p_quantity => 150,
        p_unit => 'kits',
        p_deadline_date => SYSTIMESTAMP + 10,
        p_creator_id => 4,
        p_organization_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'School Supplies',
        p_description => 'Notebooks and pens for students.',
        p_location => 'Houston, TX',
        p_category => 'EDUCATION',
        p_priority => 'LOW',
        p_status => 'ACTIVE',
        p_quantity => 300,
        p_unit => 'packs',
        p_deadline_date => SYSTIMESTAMP + 20,
        p_creator_id => 1,
        p_organization_id => 4
    );
END;
/

-- Inserir 5 doações usando INSERT_DONATION
BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'Boxed Meals',
        p_description => 'Individually packaged meals.',
        p_location => 'New York, NY',
        p_category => 'FOOD',
        p_status => 'AVAILABLE',
        p_quantity => 250,
        p_unit => 'boxes',
        p_expiry_date => SYSTIMESTAMP + 3,
        p_donor_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'Bottled Water',
        p_description => 'Mineral water bottles.',
        p_location => 'Los Angeles, CA',
        p_category => 'WATER',
        p_status => 'AVAILABLE',
        p_quantity => 600,
        p_unit => 'bottles',
        p_expiry_date => SYSTIMESTAMP + 5,
        p_donor_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'Winter Blankets',
        p_description => 'Thick blankets for cold weather.',
        p_location => 'Chicago, IL',
        p_category => 'CLOTHING',
        p_status => 'AVAILABLE',
        p_quantity => 150,
        p_unit => 'blankets',
        p_expiry_date => SYSTIMESTAMP + 7,
        p_donor_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'First Aid Kits',
        p_description => 'Complete first aid kits.',
        p_location => 'Miami, FL',
        p_category => 'MEDICAL',
        p_status => 'AVAILABLE',
        p_quantity => 100,
        p_unit => 'kits',
        p_expiry_date => SYSTIMESTAMP + 10,
        p_donor_id => 5
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'School Bags',
        p_description => 'Bags for students.',
        p_location => 'Houston, TX',
        p_category => 'EDUCATION',
        p_status => 'AVAILABLE',
        p_quantity => 120,
        p_unit => 'bags',
        p_expiry_date => SYSTIMESTAMP + 8,
        p_donor_id => 5
    );
END;
/

-- Inserir 5 matches usando INSERT_MATCH
BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 1,
        p_donation_id => 1,
        p_status => 'CONFIRMED',
        p_matched_quantity => 200,
        p_compatibility_score => 92,
        p_notes => 'Food matched for Hope Foundation'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 2,
        p_donation_id => 2,
        p_status => 'CONFIRMED',
        p_matched_quantity => 500,
        p_compatibility_score => 95,
        p_notes => 'Water matched for Water for All'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 3,
        p_donation_id => 3,
        p_status => 'CONFIRMED',
        p_matched_quantity => 120,
        p_compatibility_score => 88,
        p_notes => 'Blankets matched for City Food Bank'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 4,
        p_donation_id => 4,
        p_status => 'CONFIRMED',
        p_matched_quantity => 80,
        p_compatibility_score => 93,
        p_notes => 'Medical kits matched for Shelter United'
    );
END;
/

BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 5,
        p_donation_id => 5,
        p_status => 'CONFIRMED',
        p_matched_quantity => 100,
        p_compatibility_score => 85,
        p_notes => 'School supplies matched for Saint Mary Church'
    );
END;
/

-- =====================================================
-- CONSULTAS PARA VERIFICAR OS DADOS INSERIDOS
-- =====================================================

-- Verificar organizações
SELECT * FROM GS_organizations ORDER BY id;

-- Verificar usuários
SELECT * FROM GS_users ORDER BY id;

-- Verificar necessidades
SELECT * FROM GS_needs ORDER BY id;

-- Verificar doações
SELECT * FROM GS_donations ORDER BY id;

-- Verificar matches
SELECT * FROM GS_matches ORDER BY id;

-- Verificar auditoria
SELECT * FROM GS_auditoria ORDER BY id;

-- =====================================================
-- CONSULTA COMPLETA COM JOINS PARA VISUALIZAR MATCHES
-- =====================================================
SELECT 
    m.id as match_id,
    n.title as need_title,
    d.title as donation_title,
    m.status as match_status,
    m.matched_quantity,
    m.compatibility_score,
    o.name as organization_name,
    u.name as donor_name,
    m.notes
FROM GS_matches m
JOIN GS_needs n ON m.need_id = n.id
JOIN GS_donations d ON m.donation_id = d.id
JOIN GS_organizations o ON n.organization_id = o.id
JOIN GS_users u ON d.donor_id = u.id
ORDER BY m.id;
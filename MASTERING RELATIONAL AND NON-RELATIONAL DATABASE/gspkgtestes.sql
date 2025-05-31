-- ==============================================
-- ORGANIZATIONS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Nova organização
BEGIN
    GS_MANAGEMENT_PKG.INSERT_ORGANIZATION(
        p_name => 'Green Earth Foundation',
        p_description => 'Environmental conservation and sustainability programs.',
        p_location => 'Portland, OR',
        p_contact_email => 'info@greenearth.org',
        p_contact_phone => '555-6666',
        p_type => 'NGO'
    );
END;
/

-- UPDATE: Atualizar dados da organização Hope Foundation (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_ORGANIZATION(
        p_id => 1,
        p_description => 'Provides comprehensive aid and support to underprivileged communities worldwide.',
        p_contact_phone => '555-1199',
        p_type => 'CHARITY'
    );
END;
/

-- DELETE: Remover organização (assumindo ID 6 - Green Earth Foundation recém criada)
-- Nota: Só funcionará se não houver usuários vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_ORGANIZATION(p_id => 6);
END;
/

-- ==============================================
-- USERS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Novo usuário administrador
BEGIN
    GS_MANAGEMENT_PKG.INSERT_USER(
        p_email => 'admin@system.com',
        p_phone => '555-9999',
        p_name => 'System Administrator',
        p_password_hash => 'hashadmin123',
        p_role => 'ADMIN',
        p_is_active => 'Y',
        p_organization_id => NULL
    );
END;
/

-- UPDATE: Atualizar informações do usuário Alice (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_USER(
        p_id => 1,
        p_phone => '555-1011',
        p_name => 'Alice Smith Johnson',
        p_last_login => SYSTIMESTAMP,
        p_is_active => 'Y'
    );
END;
/

-- DELETE: Remover usuário (assumindo ID 6 - admin recém criado)
-- Nota: Só funcionará se não houver necessidades vinculadas
BEGIN
    GS_MANAGEMENT_PKG.DELETE_USER(p_id => 6);
END;
/

-- ==============================================
-- NEEDS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Nova necessidade
BEGIN
    GS_MANAGEMENT_PKG.INSERT_NEED(
        p_title => 'Emergency Shelter',
        p_description => 'Temporary shelter for families affected by flooding.',
        p_location => 'Austin, TX',
        p_category => 'SHELTER',
        p_priority => 'CRITICAL',
        p_status => 'ACTIVE',
        p_quantity => 50,
        p_unit => 'tents',
        p_deadline_date => SYSTIMESTAMP + 3,
        p_creator_id => 2,
        p_organization_id => 2
    );
END;
/

-- UPDATE: Atualizar necessidade de Canned Food (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_NEED(
        p_id => 1,
        p_priority => 'CRITICAL',
        p_status => 'PARTIALLY_FULFILLED',
        p_quantity => 300,
        p_deadline_date => SYSTIMESTAMP + 14
    );
END;
/

-- DELETE: Remover necessidade (assumindo ID 6 - Emergency Shelter recém criada)
-- Nota: Só funcionará se não houver matches vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_NEED(p_id => 6);
END;
/

-- ==============================================
-- DONATIONS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Nova doação
BEGIN
    GS_MANAGEMENT_PKG.INSERT_DONATION(
        p_title => 'Camping Equipment',
        p_description => 'Tents, sleeping bags, and camping gear.',
        p_location => 'Denver, CO',
        p_category => 'SHELTER',
        p_status => 'AVAILABLE',
        p_quantity => 75,
        p_unit => 'sets',
        p_expiry_date => SYSTIMESTAMP + 30,
        p_donor_id => 5
    );
END;
/

-- UPDATE: Atualizar doação de Boxed Meals (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_DONATION(
        p_id => 1,
        p_status => 'RESERVED',
        p_quantity => 200,
        p_expiry_date => SYSTIMESTAMP + 5
    );
END;
/

-- DELETE: Remover doação (assumindo ID 6 - Camping Equipment recém criada)
-- Nota: Só funcionará se não houver matches vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_DONATION(p_id => 6);
END;
/

-- ==============================================
-- MATCHES - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Novo match entre necessidade e doação
BEGIN
    GS_MANAGEMENT_PKG.INSERT_MATCH(
        p_need_id => 2,
        p_donation_id => 1,
        p_status => 'PENDING',
        p_matched_quantity => 150,
        p_compatibility_score => 78,
        p_notes => 'Potential match for water need with meal boxes'
    );
END;
/

-- UPDATE: Confirmar match existente (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_MATCH(
        p_id => 1,
        p_status => 'COMPLETED',
        p_matched_quantity => 90,
        p_compatibility_score => 98,
        p_confirmed_at => SYSTIMESTAMP,
        p_notes => 'Successfully completed food match for Hope Foundation'
    );
END;
/

-- DELETE: Remover match (assumindo ID 6 - match recém criado)
BEGIN
    GS_MANAGEMENT_PKG.DELETE_MATCH(p_id => 6);
END;
/

-- =====================================================
-- CONSULTAS PARA VERIFICAR AS OPERAÇÕES
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
-- CONSULTA DETALHADA DE MATCHES APÓS OPERAÇÕES
-- =====================================================
SELECT 
    m.id as match_id,
    m.status as match_status,
    n.title as need_title,
    n.category as need_category,
    n.priority as need_priority,
    n.quantity as need_quantity,
    d.title as donation_title,
    d.category as donation_category,
    d.quantity as donation_quantity,
    m.matched_quantity,
    m.compatibility_score,
    o.name as requesting_organization,
    u.name as donor_name,
    m.created_at as match_created,
    m.confirmed_at as match_confirmed,
    m.notes
FROM GS_matches m
JOIN GS_needs n ON m.need_id = n.id
JOIN GS_donations d ON m.donation_id = d.id
LEFT JOIN GS_organizations o ON n.organization_id = o.id
JOIN GS_users u ON d.donor_id = u.id
ORDER BY m.id;

-- =====================================================
-- CONSULTAS PARA ANÁLISE DE DADOS
-- =====================================================

-- Estatísticas por categoria de necessidades
SELECT 
    category,
    COUNT(*) as total_needs,
    SUM(quantity) as total_quantity,
    AVG(quantity) as avg_quantity
FROM GS_needs
GROUP BY category
ORDER BY total_needs DESC;

-- Estatísticas por categoria de doações
SELECT 
    category,
    COUNT(*) as total_donations,
    SUM(quantity) as total_quantity,
    AVG(quantity) as avg_quantity
FROM GS_donations
GROUP BY category
ORDER BY total_donations DESC;

-- Status dos matches
SELECT 
    status,
    COUNT(*) as total_matches,
    AVG(compatibility_score) as avg_compatibility,
    SUM(matched_quantity) as total_matched_quantity
FROM GS_matches
GROUP BY status
ORDER BY total_matches DESC;
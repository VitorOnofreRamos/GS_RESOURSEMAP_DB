set serveroutput on;

-- ==============================================
-- ORGANIZATIONS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Nova organiza��o
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

-- UPDATE: Atualizar dados da organiza��o Hope Foundation (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_ORGANIZATION(
        p_id => 1,
        p_description => 'Provides comprehensive aid and support to underprivileged communities worldwide.',
        p_contact_phone => '555-1199',
        p_type => 'CHARITY'
    );
END;
/

-- DELETE: Remover organiza��o (assumindo ID 6 - Green Earth Foundation rec�m criada)
-- Nota: S� funcionar� se n�o houver usu�rios vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_ORGANIZATION(p_id => 6);
END;
/

-- ==============================================
-- USERS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Novo usu�rio administrador
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

-- UPDATE: Atualizar informa��es do usu�rio Alice (ID 1)
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

-- DELETE: Remover usu�rio (assumindo ID 6 - admin rec�m criado)
-- Nota: S� funcionar� se n�o houver necessidades vinculadas
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

-- DELETE: Remover necessidade (assumindo ID 6 - Emergency Shelter rec�m criada)
-- Nota: S� funcionar� se n�o houver matches vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_NEED(p_id => 6);
END;
/

-- ==============================================
-- DONATIONS - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Nova doa��o
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

-- UPDATE: Atualizar doa��o de Boxed Meals (ID 1)
BEGIN
    GS_MANAGEMENT_PKG.UPDATE_DONATION(
        p_id => 1,
        p_status => 'RESERVED',
        p_quantity => 200,
        p_expiry_date => SYSTIMESTAMP + 5
    );
END;
/

-- DELETE: Remover doa��o (assumindo ID 6 - Camping Equipment rec�m criada)
-- Nota: S� funcionar� se n�o houver matches vinculados
BEGIN
    GS_MANAGEMENT_PKG.DELETE_DONATION(p_id => 6);
END;
/

-- ==============================================
-- MATCHES - INSERT, UPDATE, DELETE
-- ==============================================

-- INSERT: Novo match entre necessidade e doa��o
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

-- DELETE: Remover match (assumindo ID 6 - match rec�m criado)
BEGIN
    GS_MANAGEMENT_PKG.DELETE_MATCH(p_id => 6);
END;
/

-- =====================================================
-- EXEMPLO 1: Usando as fun��es
-- =====================================================
DECLARE
    v_total_needs NUMBER;
    v_efficiency NUMBER;
    v_demand_level VARCHAR2(20);
BEGIN
    -- Testar fun��o de total de necessidades ativas
    v_total_needs := GS_MANAGEMENT_PKG.get_total_active_needs();
    DBMS_OUTPUT.PUT_LINE('Total de necessidades ativas: ' || v_total_needs);
    
    -- Testar efici�ncia de uma organiza��o (assumindo ID 1)
    v_efficiency := GS_MANAGEMENT_PKG.get_organization_efficiency(1);
    DBMS_OUTPUT.PUT_LINE('Efici�ncia da organiza��o 1: ' || v_efficiency || '%');
    
    -- Testar n�vel de demanda por categoria
    v_demand_level := GS_MANAGEMENT_PKG.get_category_demand_level('FOOD');
    DBMS_OUTPUT.PUT_LINE('N�vel de demanda para FOOD: ' || v_demand_level);
    
    v_demand_level := GS_MANAGEMENT_PKG.get_category_demand_level('MEDICAL');
    DBMS_OUTPUT.PUT_LINE('N�vel de demanda para MEDICAL: ' || v_demand_level);
END;
/

-- =====================================================
-- EXEMPLO 2: Relat�rio de organiza��es com cursor
-- =====================================================
DECLARE
    v_cursor GS_MANAGEMENT_PKG.c_org_stats;
    v_record GS_MANAGEMENT_PKG.t_org_stats;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELAT�RIO DE ORGANIZA��ES ===');
    
    GS_MANAGEMENT_PKG.generate_organization_report(v_cursor);
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Organiza��o: ' || v_record.org_name);
        DBMS_OUTPUT.PUT_LINE('  Tipo: ' || NVL(v_record.org_type, 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  Usu�rios: ' || v_record.total_users);
        DBMS_OUTPUT.PUT_LINE('  Necessidades: ' || v_record.total_needs);
        DBMS_OUTPUT.PUT_LINE('  Matches: ' || v_record.total_matches);
        DBMS_OUTPUT.PUT_LINE('  Score m�dio: ' || NVL(TO_CHAR(v_record.avg_compatibility), 'N/A'));
        DBMS_OUTPUT.PUT_LINE('  ');
    END LOOP;
    
    CLOSE v_cursor;
END;
/

-- =====================================================
-- EXEMPLO 3: Relat�rio de doa��es por categoria
-- =====================================================
DECLARE
    v_cursor GS_MANAGEMENT_PKG.c_donation_report;
    v_record GS_MANAGEMENT_PKG.t_donation_report;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RELAT�RIO DE DOA��ES POR CATEGORIA ===');
    
    GS_MANAGEMENT_PKG.generate_donation_summary(v_cursor);
    
    DBMS_OUTPUT.PUT_LINE('CATEGORIA        | TOTAL | QTD_TOTAL | DISPON�VEL | DOADA | M�DIA');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------');
    
    LOOP
        FETCH v_cursor INTO v_record;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_record.category, 16) || ' | ' ||
            LPAD(v_record.total_donations, 5) || ' | ' ||
            LPAD(v_record.total_quantity, 9) || ' | ' ||
            LPAD(v_record.available_qty, 10) || ' | ' ||
            LPAD(v_record.donated_qty, 5) || ' | ' ||
            LPAD(TO_CHAR(v_record.avg_quantity, '999.99'), 6)
        );
    END LOOP;
    
    CLOSE v_cursor;
END;
/

-- =====================================================
-- EXEMPLO 4: Relat�rio de efici�ncia de matching
-- =====================================================
BEGIN
    GS_MANAGEMENT_PKG.generate_matching_efficiency_report();
END;
/

-- =====================================================
-- EXEMPLO 5: Relat�rio de atividade mensal
-- =====================================================
BEGIN
    -- Relat�rio para junho de 2025
    GS_MANAGEMENT_PKG.generate_monthly_activity_report(2025, 6);
END;
/

-- =====================================================
-- CONSULTAS PARA VERIFICAR AS OPERA��ES
-- =====================================================

-- Verificar organiza��es
SELECT * FROM GS_organizations ORDER BY id;

-- Verificar usu�rios
SELECT * FROM GS_users ORDER BY id;

-- Verificar necessidades
SELECT * FROM GS_needs ORDER BY id;

-- Verificar doa��es
SELECT * FROM GS_donations ORDER BY id;

-- Verificar matches
SELECT * FROM GS_matches ORDER BY id;

-- Verificar auditoria
SELECT * FROM GS_auditoria ORDER BY id;

-- =====================================================
-- CONSULTA DETALHADA DE MATCHES AP�S OPERA��ES
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
-- CONSULTAS PARA AN�LISE DE DADOS
-- =====================================================

-- Estat�sticas por categoria de necessidades
SELECT 
    category,
    COUNT(*) as total_needs,
    SUM(quantity) as total_quantity,
    AVG(quantity) as avg_quantity
FROM GS_needs
GROUP BY category
ORDER BY total_needs DESC;

-- Estat�sticas por categoria de doa��es
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
-- =====================================================
-- PACKAGE HEADER - Sistema de Doa��es e Necessidades
-- =====================================================

CREATE OR REPLACE PACKAGE PKG_DONATION_SYSTEM AS
    
    -- Exce��es customizadas
    exc_invalid_user EXCEPTION;
    exc_invalid_organization EXCEPTION;
    exc_invalid_data EXCEPTION;
    exc_business_rule EXCEPTION;
    
    -- Procedures de Inser��o
    PROCEDURE SP_INSERT_ORGANIZATION(
        p_name VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_contact_email VARCHAR2,
        p_contact_phone VARCHAR2,
        p_type VARCHAR2,
        p_id OUT NUMBER
    );
    
    PROCEDURE SP_INSERT_USER(
        p_email VARCHAR2,
        p_name VARCHAR2,
        p_password_hash VARCHAR2,
        p_role VARCHAR2,
        p_phone VARCHAR2 DEFAULT NULL,
        p_organization_id NUMBER DEFAULT NULL,
        p_id OUT NUMBER
    );
    
    PROCEDURE SP_INSERT_NEED(
        p_title VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_category VARCHAR2,
        p_priority VARCHAR2,
        p_quantity NUMBER,
        p_unit VARCHAR2,
        p_deadline_date TIMESTAMP,
        p_creator_id NUMBER,
        p_organization_id NUMBER,
        p_id OUT NUMBER
    );
    
    PROCEDURE SP_INSERT_DONATION(
        p_title VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_category VARCHAR2,
        p_quantity NUMBER,
        p_unit VARCHAR2,
        p_expiry_date TIMESTAMP,
        p_donor_id NUMBER,
        p_id OUT NUMBER
    );
    
    -- Procedures de Altera��o
    PROCEDURE SP_UPDATE_NEED_STATUS(
        p_need_id NUMBER,
        p_status VARCHAR2,
        p_user_id NUMBER
    );
    
    PROCEDURE SP_UPDATE_DONATION_STATUS(
        p_donation_id NUMBER,
        p_status VARCHAR2,
        p_user_id NUMBER
    );
    
    PROCEDURE SP_UPDATE_USER_PROFILE(
        p_user_id NUMBER,
        p_name VARCHAR2,
        p_phone VARCHAR2,
        p_contact_email VARCHAR2
    );
    
    -- Procedures de Exclus�o (Soft Delete)
    PROCEDURE SP_DELETE_NEED(
        p_need_id NUMBER,
        p_user_id NUMBER
    );
    
    PROCEDURE SP_DELETE_DONATION(
        p_donation_id NUMBER,
        p_user_id NUMBER
    );
    
    -- Fun��es de C�lculo e Ranking
    FUNCTION FN_CALCULATE_COMPATIBILITY_SCORE(
        p_need_id NUMBER,
        p_donation_id NUMBER
    ) RETURN NUMBER;
    
    FUNCTION FN_GET_USER_DONATION_RANKING(
        p_user_id NUMBER
    ) RETURN NUMBER;
    
    FUNCTION FN_CALCULATE_URGENCY_SCORE(
        p_need_id NUMBER
    ) RETURN NUMBER;
    
    FUNCTION FN_GET_ORGANIZATION_RISK_LEVEL(
        p_organization_id NUMBER
    ) RETURN VARCHAR2;
    
    -- Procedure para Matching Autom�tico
    PROCEDURE SP_AUTO_MATCH_DONATIONS;
    
    -- Procedure de Relat�rios
    PROCEDURE SP_GENERATE_MONTHLY_REPORT(
        p_month NUMBER,
        p_year NUMBER
    );
    
    PROCEDURE SP_GENERATE_ORGANIZATION_SUMMARY(
        p_organization_id NUMBER
    );
    
END PKG_DONATION_SYSTEM;
/

-- =====================================================
-- PACKAGE BODY - Implementa��o
-- =====================================================

CREATE OR REPLACE PACKAGE BODY PKG_DONATION_SYSTEM AS

    -- =====================================================
    -- PROCEDURES DE INSER��O
    -- =====================================================
    
    PROCEDURE SP_INSERT_ORGANIZATION(
        p_name VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_contact_email VARCHAR2,
        p_contact_phone VARCHAR2,
        p_type VARCHAR2,
        p_id OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Valida��o de entrada
        IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
            RAISE exc_invalid_data;
        END IF;
        
        -- Verifica se organiza��o j� existe
        SELECT COUNT(*) INTO v_count
        FROM GS_organizations
        WHERE UPPER(name) = UPPER(p_name)
        AND location = p_location;
        
        IF v_count > 0 THEN
            RAISE exc_business_rule;
        END IF;
        
        -- Insere nova organiza��o
        INSERT INTO GS_organizations (
            name, description, location, contact_email, 
            contact_phone, type, created_at, updated_at
        ) VALUES (
            p_name, p_description, p_location, p_contact_email,
            p_contact_phone, p_type, SYSTIMESTAMP, SYSTIMESTAMP
        ) RETURNING id INTO p_id;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Organiza��o criada com sucesso. ID: ' || p_id);
        
    EXCEPTION
        WHEN exc_invalid_data THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Dados inv�lidos: Nome � obrigat�rio');
        WHEN exc_business_rule THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Organiza��o j� existe neste local');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Erro inesperado: ' || SQLERRM);
    END SP_INSERT_ORGANIZATION;

    PROCEDURE SP_INSERT_USER(
        p_email VARCHAR2,
        p_name VARCHAR2,
        p_password_hash VARCHAR2,
        p_role VARCHAR2,
        p_phone VARCHAR2 DEFAULT NULL,
        p_organization_id NUMBER DEFAULT NULL,
        p_id OUT NUMBER
    ) IS
        v_count NUMBER;
        v_org_exists NUMBER := 0;
    BEGIN
        -- Valida��es
        IF p_email IS NULL OR p_name IS NULL OR p_password_hash IS NULL THEN
            RAISE exc_invalid_data;
        END IF;
        
        -- Verifica se email j� existe
        SELECT COUNT(*) INTO v_count
        FROM GS_users
        WHERE email = p_email;
        
        IF v_count > 0 THEN
            RAISE exc_business_rule;
        END IF;
        
        -- Verifica se organiza��o existe (se informada)
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_exists
            FROM GS_organizations
            WHERE id = p_organization_id;
            
            IF v_org_exists = 0 THEN
                RAISE exc_invalid_organization;
            END IF;
        END IF;
        
        -- Insere usu�rio
        INSERT INTO GS_users (
            email, name, password_hash, role, phone,
            organization_id, created_at, updated_at, is_active
        ) VALUES (
            p_email, p_name, p_password_hash, p_role, p_phone,
            p_organization_id, SYSTIMESTAMP, SYSTIMESTAMP, 'Y'
        ) RETURNING id INTO p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN exc_invalid_data THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20004, 'Dados obrigat�rios n�o informados');
        WHEN exc_business_rule THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Email j� cadastrado');
        WHEN exc_invalid_organization THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20006, 'Organiza��o n�o encontrada');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_USER;

    PROCEDURE SP_INSERT_NEED(
        p_title VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_category VARCHAR2,
        p_priority VARCHAR2,
        p_quantity NUMBER,
        p_unit VARCHAR2,
        p_deadline_date TIMESTAMP,
        p_creator_id NUMBER,
        p_organization_id NUMBER,
        p_id OUT NUMBER
    ) IS
        v_user_exists NUMBER;
        v_org_exists NUMBER;
    BEGIN
        -- Valida��es b�sicas
        IF p_title IS NULL OR p_quantity <= 0 OR p_creator_id IS NULL THEN
            RAISE exc_invalid_data;
        END IF;
        
        -- Verifica se usu�rio existe
        SELECT COUNT(*) INTO v_user_exists
        FROM GS_users
        WHERE id = p_creator_id AND is_active = 'Y';
        
        IF v_user_exists = 0 THEN
            RAISE exc_invalid_user;
        END IF;
        
        -- Verifica organiza��o se informada
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_exists
            FROM GS_organizations
            WHERE id = p_organization_id;
            
            IF v_org_exists = 0 THEN
                RAISE exc_invalid_organization;
            END IF;
        END IF;
        
        -- Insere necessidade
        INSERT INTO GS_needs (
            title, description, location, category, priority,
            status, quantity, unit, deadline_date, created_at,
            updated_at, creator_id, organization_id
        ) VALUES (
            p_title, p_description, p_location, p_category, p_priority,
            'ACTIVE', p_quantity, p_unit, p_deadline_date, SYSTIMESTAMP,
            SYSTIMESTAMP, p_creator_id, p_organization_id
        ) RETURNING id INTO p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN exc_invalid_data THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20007, 'Dados da necessidade inv�lidos');
        WHEN exc_invalid_user THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20008, 'Usu�rio n�o encontrado ou inativo');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_NEED;

    PROCEDURE SP_INSERT_DONATION(
        p_title VARCHAR2,
        p_description CLOB,
        p_location VARCHAR2,
        p_category VARCHAR2,
        p_quantity NUMBER,
        p_unit VARCHAR2,
        p_expiry_date TIMESTAMP,
        p_donor_id NUMBER,
        p_id OUT NUMBER
    ) IS
        v_donor_exists NUMBER;
    BEGIN
        -- Valida��es
        IF p_title IS NULL OR p_quantity <= 0 OR p_donor_id IS NULL THEN
            RAISE exc_invalid_data;
        END IF;
        
        -- Verifica se doador existe
        SELECT COUNT(*) INTO v_donor_exists
        FROM GS_users
        WHERE id = p_donor_id AND is_active = 'Y';
        
        IF v_donor_exists = 0 THEN
            RAISE exc_invalid_user;
        END IF;
        
        -- Insere doa��o
        INSERT INTO GS_donations (
            title, description, location, category, status,
            quantity, unit, expiry_date, created_at,
            updated_at, donor_id
        ) VALUES (
            p_title, p_description, p_location, p_category, 'AVAILABLE',
            p_quantity, p_unit, p_expiry_date, SYSTIMESTAMP,
            SYSTIMESTAMP, p_donor_id
        ) RETURNING id INTO p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN exc_invalid_data THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20009, 'Dados da doa��o inv�lidos');
        WHEN exc_invalid_user THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20010, 'Doador n�o encontrado');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_DONATION;

    -- =====================================================
    -- PROCEDURES DE ALTERA��O
    -- =====================================================
    
    PROCEDURE SP_UPDATE_NEED_STATUS(
        p_need_id NUMBER,
        p_status VARCHAR2,
        p_user_id NUMBER
    ) IS
        v_current_status VARCHAR2(20);
        v_user_role VARCHAR2(20);
    BEGIN
        -- Busca status atual e valida usu�rio
        SELECT n.status, u.role 
        INTO v_current_status, v_user_role
        FROM GS_needs n
        JOIN GS_users u ON (u.id = p_user_id)
        WHERE n.id = p_need_id;
        
        -- Regras de neg�cio para mudan�a de status
        IF v_current_status = 'FULFILLED' AND p_status != 'FULFILLED' THEN
            IF v_user_role != 'ADMIN' THEN
                RAISE exc_business_rule;
            END IF;
        END IF;
        
        -- Atualiza status
        UPDATE GS_needs 
        SET status = p_status, updated_at = SYSTIMESTAMP
        WHERE id = p_need_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20011, 'Necessidade ou usu�rio n�o encontrado');
        WHEN exc_business_rule THEN
            RAISE_APPLICATION_ERROR(-20012, 'Opera��o n�o permitida para este usu�rio');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_NEED_STATUS;

    PROCEDURE SP_UPDATE_DONATION_STATUS(
        p_donation_id NUMBER,
        p_status VARCHAR2,
        p_user_id NUMBER
    ) IS
        v_donor_id NUMBER;
        v_user_role VARCHAR2(20);
    BEGIN
        -- Verifica se usu�rio pode alterar esta doa��o
        SELECT d.donor_id, u.role 
        INTO v_donor_id, v_user_role
        FROM GS_donations d
        JOIN GS_users u ON (u.id = p_user_id)
        WHERE d.id = p_donation_id;
        
        -- Verifica permiss�o
        IF v_donor_id != p_user_id AND v_user_role != 'ADMIN' THEN
            RAISE exc_business_rule;
        END IF;
        
        -- Atualiza status
        UPDATE GS_donations 
        SET status = p_status, updated_at = SYSTIMESTAMP
        WHERE id = p_donation_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20013, 'Doa��o n�o encontrada');
        WHEN exc_business_rule THEN
            RAISE_APPLICATION_ERROR(-20014, 'Usu�rio sem permiss�o para alterar esta doa��o');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_DONATION_STATUS;

    PROCEDURE SP_UPDATE_USER_PROFILE(
        p_user_id NUMBER,
        p_name VARCHAR2,
        p_phone VARCHAR2,
        p_contact_email VARCHAR2
    ) IS
    BEGIN
        UPDATE GS_users 
        SET name = NVL(p_name, name),
            phone = NVL(p_phone, phone),
            updated_at = SYSTIMESTAMP
        WHERE id = p_user_id AND is_active = 'Y';
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE exc_invalid_user;
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN exc_invalid_user THEN
            RAISE_APPLICATION_ERROR(-20015, 'Usu�rio n�o encontrado');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_USER_PROFILE;

    -- =====================================================
    -- PROCEDURES DE EXCLUS�O (SOFT DELETE)
    -- =====================================================
    
    PROCEDURE SP_DELETE_NEED(
        p_need_id NUMBER,
        p_user_id NUMBER
    ) IS
        v_creator_id NUMBER;
        v_user_role VARCHAR2(20);
    BEGIN
        -- Verifica permiss�o
        SELECT n.creator_id, u.role 
        INTO v_creator_id, v_user_role
        FROM GS_needs n
        JOIN GS_users u ON (u.id = p_user_id)
        WHERE n.id = p_need_id;
        
        IF v_creator_id != p_user_id AND v_user_role != 'ADMIN' THEN
            RAISE exc_business_rule;
        END IF;
        
        -- Soft delete - marca como cancelada
        UPDATE GS_needs 
        SET status = 'CANCELLED', updated_at = SYSTIMESTAMP
        WHERE id = p_need_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20016, 'Necessidade n�o encontrada');
        WHEN exc_business_rule THEN
            RAISE_APPLICATION_ERROR(-20017, 'Sem permiss�o para excluir esta necessidade');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_NEED;

    PROCEDURE SP_DELETE_DONATION(
        p_donation_id NUMBER,
        p_user_id NUMBER
    ) IS
        v_donor_id NUMBER;
        v_user_role VARCHAR2(20);
        v_current_status VARCHAR2(20);
    BEGIN
        -- Verifica permiss�o e status
        SELECT d.donor_id, u.role, d.status 
        INTO v_donor_id, v_user_role, v_current_status
        FROM GS_donations d
        JOIN GS_users u ON (u.id = p_user_id)
        WHERE d.id = p_donation_id;
        
        IF v_donor_id != p_user_id AND v_user_role != 'ADMIN' THEN
            RAISE exc_business_rule;
        END IF;
        
        -- N�o pode excluir se j� foi doada
        IF v_current_status = 'DONATED' THEN
            RAISE exc_business_rule;
        END IF;
        
        -- Soft delete
        UPDATE GS_donations 
        SET status = 'EXPIRED', updated_at = SYSTIMESTAMP
        WHERE id = p_donation_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20018, 'Doa��o n�o encontrada');
        WHEN exc_business_rule THEN
            RAISE_APPLICATION_ERROR(-20019, 'Opera��o n�o permitida');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_DONATION;

    -- =====================================================
    -- FUN��ES DE C�LCULO E RANKING
    -- =====================================================
    
    FUNCTION FN_CALCULATE_COMPATIBILITY_SCORE(
        p_need_id NUMBER,
        p_donation_id NUMBER
    ) RETURN NUMBER IS
        v_need_category VARCHAR2(20);
        v_need_location VARCHAR2(255);
        v_need_quantity NUMBER;
        v_need_priority VARCHAR2(10);
        v_donation_category VARCHAR2(20);
        v_donation_location VARCHAR2(255);
        v_donation_quantity NUMBER;
        v_score NUMBER := 0;
        v_location_distance NUMBER := 0;
    BEGIN
        -- Busca dados da necessidade
        SELECT category, location, quantity, priority
        INTO v_need_category, v_need_location, v_need_quantity, v_need_priority
        FROM GS_needs
        WHERE id = p_need_id;
        
        -- Busca dados da doa��o
        SELECT category, location, quantity
        INTO v_donation_category, v_donation_location, v_donation_quantity
        FROM GS_donations
        WHERE id = p_donation_id;
        
        -- Categoria compat�vel (40% do score)
        IF v_need_category = v_donation_category THEN
            v_score := v_score + 0.4;
        END IF;
        
        -- Localiza��o (30% do score)
        IF UPPER(v_need_location) = UPPER(v_donation_location) THEN
            v_score := v_score + 0.3;
        ELSIF INSTR(UPPER(v_need_location), UPPER(SUBSTR(v_donation_location, 1, 10))) > 0 THEN
            v_score := v_score + 0.15; -- Localiza��o parcialmente compat�vel
        END IF;
        
        -- Quantidade (20% do score)
        IF v_donation_quantity >= v_need_quantity THEN
            v_score := v_score + 0.2;
        ELSIF v_donation_quantity >= (v_need_quantity * 0.5) THEN
            v_score := v_score + 0.1; -- Atende pelo menos 50%
        END IF;
        
        -- Urg�ncia (10% do score)
        CASE v_need_priority
            WHEN 'CRITICAL' THEN v_score := v_score + 0.1;
            WHEN 'HIGH' THEN v_score := v_score + 0.08;
            WHEN 'MEDIUM' THEN v_score := v_score + 0.05;
            ELSE v_score := v_score + 0.02;
        END CASE;
        
        RETURN ROUND(v_score, 2);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END FN_CALCULATE_COMPATIBILITY_SCORE;

    FUNCTION FN_GET_USER_DONATION_RANKING(
        p_user_id NUMBER
    ) RETURN NUMBER IS
        v_total_donations NUMBER := 0;
        v_total_value NUMBER := 0;
        v_recent_donations NUMBER := 0;
        v_ranking NUMBER := 0;
    BEGIN
        -- Conta doa��es do usu�rio
        SELECT COUNT(*), 
               COUNT(CASE WHEN created_at >= SYSTIMESTAMP - 30 THEN 1 END)
        INTO v_total_donations, v_recent_donations
        FROM GS_donations
        WHERE donor_id = p_user_id
        AND status IN ('DONATED', 'RESERVED');
        
        -- Calcula ranking baseado em doa��es
        v_ranking := (v_total_donations * 10) + (v_recent_donations * 5);
        
        -- B�nus para usu�rios muito ativos
        IF v_total_donations > 50 THEN
            v_ranking := v_ranking + 100;
        ELSIF v_total_donations > 20 THEN
            v_ranking := v_ranking + 50;
        ELSIF v_total_donations > 10 THEN
            v_ranking := v_ranking + 20;
        END IF;
        
        RETURN v_ranking;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END FN_GET_USER_DONATION_RANKING;

    FUNCTION FN_CALCULATE_URGENCY_SCORE(
        p_need_id NUMBER
    ) RETURN NUMBER IS
        v_priority VARCHAR2(10);
        v_deadline_date TIMESTAMP;
        v_created_at TIMESTAMP;
        v_days_until_deadline NUMBER;
        v_days_since_created NUMBER;
        v_urgency_score NUMBER := 0;
    BEGIN
        SELECT priority, deadline_date, created_at
        INTO v_priority, v_deadline_date, v_created_at
        FROM GS_needs
        WHERE id = p_need_id;
        
        -- Score base por prioridade
        CASE v_priority
            WHEN 'CRITICAL' THEN v_urgency_score := 100;
            WHEN 'HIGH' THEN v_urgency_score := 75;
            WHEN 'MEDIUM' THEN v_urgency_score := 50;
            WHEN 'LOW' THEN v_urgency_score := 25;
            ELSE v_urgency_score := 10;
        END CASE;
        
        -- Ajuste por prazo
        IF v_deadline_date IS NOT NULL THEN
            v_days_until_deadline := EXTRACT(DAY FROM (v_deadline_date - SYSTIMESTAMP));
            
            IF v_days_until_deadline <= 1 THEN
                v_urgency_score := v_urgency_score + 50;
            ELSIF v_days_until_deadline <= 3 THEN
                v_urgency_score := v_urgency_score + 30;
            ELSIF v_days_until_deadline <= 7 THEN
                v_urgency_score := v_urgency_score + 15;
            END IF;
        END IF;
        
        -- Ajuste por tempo de espera
        v_days_since_created := EXTRACT(DAY FROM (SYSTIMESTAMP - v_created_at));
        IF v_days_since_created > 30 THEN
            v_urgency_score := v_urgency_score + 25;
        ELSIF v_days_since_created > 14 THEN
            v_urgency_score := v_urgency_score + 15;
        ELSIF v_days_since_created > 7 THEN
            v_urgency_score := v_urgency_score + 10;
        END IF;
        
        RETURN LEAST(v_urgency_score, 200); -- M�ximo 200
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END FN_CALCULATE_URGENCY_SCORE;

    FUNCTION FN_GET_ORGANIZATION_RISK_LEVEL(
        p_organization_id NUMBER
    ) RETURN VARCHAR2 IS
        v_total_needs NUMBER := 0;
        v_fulfilled_needs NUMBER := 0;
        v_overdue_needs NUMBER := 0;
        v_success_rate NUMBER := 0;
        v_risk_level VARCHAR2(10) := 'LOW';
        v_days_active NUMBER;
        v_created_at TIMESTAMP;
    BEGIN
        -- Busca data de cria��o da organiza��o
        SELECT created_at INTO v_created_at
        FROM GS_organizations
        WHERE id = p_organization_id;
        
        v_days_active := EXTRACT(DAY FROM (SYSTIMESTAMP - v_created_at));
        
        -- Conta necessidades por status
        SELECT COUNT(*),
               SUM(CASE WHEN status = 'FULFILLED' THEN 1 ELSE 0 END),
               SUM(CASE WHEN status = 'ACTIVE' AND deadline_date < SYSTIMESTAMP THEN 1 ELSE 0 END)
        INTO v_total_needs, v_fulfilled_needs, v_overdue_needs
        FROM GS_needs
        WHERE organization_id = p_organization_id;
        
        -- Calcula taxa de sucesso
        IF v_total_needs > 0 THEN
            v_success_rate := (v_fulfilled_needs / v_total_needs) * 100;
        END IF;
        
        -- Determina n�vel de risco
        IF v_overdue_needs > 5 OR v_success_rate < 30 THEN
            v_risk_level := 'HIGH';
        ELSIF v_overdue_needs > 2 OR v_success_rate < 60 THEN
            v_risk_level := 'MEDIUM';
        ELSIF v_days_active < 30 THEN
            v_risk_level := 'MEDIUM'; -- Organiza��o nova
        ELSE
            v_risk_level := 'LOW';
        END IF;
        
        RETURN v_risk_level;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'UNKNOWN';
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END FN_GET_ORGANIZATION_RISK_LEVEL;

    -- =====================================================
    -- PROCEDURE DE MATCHING AUTOM�TICO COM CURSOR E LOOP
    -- =====================================================
    
    PROCEDURE SP_AUTO_MATCH_DONATIONS IS
        -- Cursor para necessidades ativas
        CURSOR c_active_needs IS
            SELECT id, category, location, quantity, priority, creator_id
            FROM GS_needs
            WHERE status = 'ACTIVE'
            AND deadline_date > SYSTIMESTAMP
            ORDER BY 
                CASE priority
                    WHEN 'CRITICAL' THEN 1
                    WHEN 'HIGH' THEN 2
                    WHEN 'MEDIUM' THEN 3
                    ELSE 4
                END,
                created_at;
        
        -- Cursor para doa��es dispon�veis
        CURSOR c_available_donations(p_category VARCHAR2, p_location VARCHAR2) IS
            SELECT id, quantity, donor_id, location
            FROM GS_donations
            WHERE status = 'AVAILABLE'
            AND category = p_category
            AND (UPPER(location) = UPPER(p_location) 
                 OR INSTR(UPPER(location), UPPER(SUBSTR(p_location, 1, 10))) > 0)
            ORDER BY created_at;
        
        v_compatibility_score NUMBER;
        v_matched_quantity NUMBER;
        v_match_count NUMBER := 0;
        v_total_processed NUMBER := 0;
        
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Iniciando Matching Autom�tico ===');
        
        -- Loop atrav�s das necessidades ativas
        FOR need_rec IN c_active_needs LOOP
            v_total_processed := v_total_processed + 1;
            
            -- Bloco an�nimo com controle de fluxo
            DECLARE
                v_need_fulfilled BOOLEAN := FALSE;
            BEGIN
                -- Loop atrav�s das doa��es compat�veis
                FOR donation_rec IN c_available_donations(need_rec.category, need_rec.location) LOOP
                    
                    -- Calcula score de compatibilidade
                    v_compatibility_score := FN_CALCULATE_COMPATIBILITY_SCORE(
                        need_rec.id, 
                        donation_rec.id
                    );
                    
                    -- Se score � aceit�vel (>= 0.6), cria match
                    IF v_compatibility_score >= 0.6 THEN
                        v_matched_quantity := LEAST(need_rec.quantity, donation_rec.quantity);
                        
                        -- Insere match
                        INSERT INTO GS_matches (
                            need_id, donation_id, status, matched_quantity,
                            compatibility_score, created_at, updated_at
                        ) VALUES (
                            need_rec.id, donation_rec.id, 'PENDING',
                            v_matched_quantity, v_compatibility_score,
                            SYSTIMESTAMP, SYSTIMESTAMP
                        );
                        
                        -- Atualiza status da doa��o para reservada
                        UPDATE GS_donations 
                        SET status = 'RESERVED', updated_at = SYSTIMESTAMP
                        WHERE id = donation_rec.id;
                        
                        v_match_count := v_match_count + 1;
                        
                        DBMS_OUTPUT.PUT_LINE('Match criado: Need ' || need_rec.id || 
                                           ' <-> Donation ' || donation_rec.id ||
                                           ' (Score: ' || v_compatibility_score || ')');
                        
                        -- Se doa��o atende completamente a necessidade
                        IF donation_rec.quantity >= need_rec.quantity THEN
                            UPDATE GS_needs 
                            SET status = 'PARTIALLY_FULFILLED', updated_at = SYSTIMESTAMP
                            WHERE id = need_rec.id;
                            v_need_fulfilled := TRUE;
                            EXIT; -- Sai do loop de doa��es
                        END IF;
                    END IF;
                END LOOP;
                
                -- Se necessidade n�o foi atendida, verifica urg�ncia
                IF NOT v_need_fulfilled THEN
                    DECLARE
                        v_urgency_score NUMBER;
                    BEGIN
                        v_urgency_score := FN_CALCULATE_URGENCY_SCORE(need_rec.id);
                        
                        IF v_urgency_score > 150 THEN
                            DBMS_OUTPUT.PUT_LINE('ALERTA: Necessidade cr�tica sem match - ID: ' || 
                                               need_rec.id || ' (Urg�ncia: ' || v_urgency_score || ')');
                        END IF;
                    END;
                END IF;
            END;
        END LOOP;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('=== Matching Conclu�do ===');
        DBMS_OUTPUT.PUT_LINE('Necessidades processadas: ' || v_total_processed);
        DBMS_OUTPUT.PUT_LINE('Matches criados: ' || v_match_count);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erro no matching autom�tico: ' || SQLERRM);
            RAISE;
    END SP_AUTO_MATCH_DONATIONS;

    -- =====================================================
    -- PROCEDURES DE RELAT�RIOS COMPLEXOS
    -- =====================================================
    
    PROCEDURE SP_GENERATE_MONTHLY_REPORT(
        p_month NUMBER,
        p_year NUMBER
    ) IS
        CURSOR c_monthly_stats IS
            SELECT 
                o.name as organization_name,
                o.type,
                COUNT(DISTINCT n.id) as total_needs,
                COUNT(DISTINCT CASE WHEN n.status = 'FULFILLED' THEN n.id END) as fulfilled_needs,
                COUNT(DISTINCT d.id) as total_donations,
                COUNT(DISTINCT CASE WHEN d.status = 'DONATED' THEN d.id END) as completed_donations,
                COUNT(DISTINCT m.id) as total_matches,
                ROUND(AVG(m.compatibility_score), 2) as avg_compatibility,
                COUNT(DISTINCT u.id) as active_users
            FROM GS_organizations o
            LEFT JOIN GS_needs n ON o.id = n.organization_id 
                AND EXTRACT(MONTH FROM n.created_at) = p_month
                AND EXTRACT(YEAR FROM n.created_at) = p_year
            LEFT JOIN GS_users u ON o.id = u.organization_id AND u.is_active = 'Y'
            LEFT JOIN GS_donations d ON u.id = d.donor_id
                AND EXTRACT(MONTH FROM d.created_at) = p_month
                AND EXTRACT(YEAR FROM d.created_at) = p_year
            LEFT JOIN GS_matches m ON (n.id = m.need_id OR d.id = m.donation_id)
                AND EXTRACT(MONTH FROM m.created_at) = p_month
                AND EXTRACT(YEAR FROM m.created_at) = p_year
            GROUP BY o.id, o.name, o.type
            HAVING COUNT(DISTINCT n.id) > 0 OR COUNT(DISTINCT d.id) > 0
            ORDER BY total_needs DESC, completed_donations DESC;
        
        -- Cursor para estat�sticas por categoria
        CURSOR c_category_stats IS
            SELECT 
                COALESCE(n.category, d.category) as category,
                COUNT(DISTINCT n.id) as needs_count,
                COUNT(DISTINCT d.id) as donations_count,
                COUNT(DISTINCT m.id) as matches_count,
                ROUND(
                    COUNT(DISTINCT CASE WHEN n.status = 'FULFILLED' THEN n.id END) * 100.0 / 
                    NULLIF(COUNT(DISTINCT n.id), 0), 2
                ) as fulfillment_rate
            FROM GS_needs n
            FULL OUTER JOIN GS_donations d ON n.category = d.category
                AND EXTRACT(MONTH FROM d.created_at) = p_month
                AND EXTRACT(YEAR FROM d.created_at) = p_year
            LEFT JOIN GS_matches m ON (n.id = m.need_id AND d.id = m.donation_id)
            WHERE (EXTRACT(MONTH FROM n.created_at) = p_month AND EXTRACT(YEAR FROM n.created_at) = p_year)
               OR (EXTRACT(MONTH FROM d.created_at) = p_month AND EXTRACT(YEAR FROM d.created_at) = p_year)
            GROUP BY COALESCE(n.category, d.category)
            ORDER BY needs_count DESC;
        
        v_total_orgs NUMBER := 0;
        v_total_users NUMBER := 0;
        v_month_name VARCHAR2(20);
        
    BEGIN
        -- Define nome do m�s
        SELECT TO_CHAR(TO_DATE(p_month, 'MM'), 'Month', 'NLS_DATE_LANGUAGE=Portuguese')
        INTO v_month_name FROM DUAL;
        
        DBMS_OUTPUT.PUT_LINE('=====================================');
        DBMS_OUTPUT.PUT_LINE('RELAT�RIO MENSAL - ' || TRIM(v_month_name) || '/' || p_year);
        DBMS_OUTPUT.PUT_LINE('=====================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Estat�sticas gerais
        SELECT COUNT(DISTINCT o.id), COUNT(DISTINCT u.id)
        INTO v_total_orgs, v_total_users
        FROM GS_organizations o
        LEFT JOIN GS_users u ON o.id = u.organization_id AND u.is_active = 'Y';
        
        DBMS_OUTPUT.PUT_LINE('RESUMO EXECUTIVO:');
        DBMS_OUTPUT.PUT_LINE('- Organiza��es ativas: ' || v_total_orgs);
        DBMS_OUTPUT.PUT_LINE('- Usu�rios ativos: ' || v_total_users);
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Relat�rio por organiza��o
        DBMS_OUTPUT.PUT_LINE('DESEMPENHO POR ORGANIZA��O:');
        DBMS_OUTPUT.PUT_LINE(RPAD('Organiza��o', 30) || RPAD('Tipo', 15) || 
                           RPAD('Necessidades', 12) || RPAD('Atendidas', 10) || 
                           RPAD('Doa��es', 8) || RPAD('Matches', 8) || 'Score M�dio');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 95, '-'));
        
        FOR org_rec IN c_monthly_stats LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(SUBSTR(org_rec.organization_name, 1, 29), 30) ||
                RPAD(SUBSTR(org_rec.type, 1, 14), 15) ||
                RPAD(org_rec.total_needs, 12) ||
                RPAD(org_rec.fulfilled_needs, 10) ||
                RPAD(org_rec.total_donations, 8) ||
                RPAD(org_rec.total_matches, 8) ||
                NVL(TO_CHAR(org_rec.avg_compatibility), 'N/A')
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('ESTAT�STICAS POR CATEGORIA:');
        DBMS_OUTPUT.PUT_LINE(RPAD('Categoria', 15) || RPAD('Necessidades', 12) || 
                           RPAD('Doa��es', 8) || RPAD('Matches', 8) || 'Taxa Atend.(%)');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 55, '-'));
        
        FOR cat_rec IN c_category_stats LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(cat_rec.category, 15) ||
                RPAD(cat_rec.needs_count, 12) ||
                RPAD(cat_rec.donations_count, 8) ||
                RPAD(cat_rec.matches_count, 8) ||
                NVL(TO_CHAR(cat_rec.fulfillment_rate), '0') || '%'
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Relat�rio gerado em: ' || TO_CHAR(SYSTIMESTAMP, 'DD/MM/YYYY HH24:MI:SS'));
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao gerar relat�rio: ' || SQLERRM);
    END SP_GENERATE_MONTHLY_REPORT;

    PROCEDURE SP_GENERATE_ORGANIZATION_SUMMARY(
        p_organization_id NUMBER
    ) IS
        -- Informa��es da organiza��o
        v_org_name VARCHAR2(255);
        v_org_type VARCHAR2(20);
        v_org_location VARCHAR2(255);
        v_org_created TIMESTAMP;
        v_risk_level VARCHAR2(10);
        
        -- Cursor para usu�rios da organiza��o
        CURSOR c_org_users IS
            SELECT u.id, u.name, u.email, u.role, u.created_at,
                   PKG_DONATION_SYSTEM.FN_GET_USER_DONATION_RANKING(u.id) as ranking
            FROM GS_users u
            WHERE u.organization_id = p_organization_id
            AND u.is_active = 'Y'
            ORDER BY ranking DESC, u.created_at;
        
        -- Cursor para necessidades cr�ticas
        CURSOR c_critical_needs IS
            SELECT n.id, n.title, n.priority, n.status, n.deadline_date,
                   PKG_DONATION_SYSTEM.FN_CALCULATE_URGENCY_SCORE(n.id) as urgency_score
            FROM GS_needs n
            WHERE n.organization_id = p_organization_id
            AND n.status IN ('ACTIVE', 'PARTIALLY_FULFILLED')
            ORDER BY urgency_score DESC, n.deadline_date;
        
        -- Estat�sticas agregadas
        v_total_needs NUMBER;
        v_fulfilled_needs NUMBER;
        v_total_donations NUMBER;
        v_active_matches NUMBER;
        v_success_rate NUMBER;
        
    BEGIN
        -- Busca informa��es da organiza��o
        SELECT name, type, location, created_at
        INTO v_org_name, v_org_type, v_org_location, v_org_created
        FROM GS_organizations
        WHERE id = p_organization_id;
        
        -- Calcula n�vel de risco
        v_risk_level := FN_GET_ORGANIZATION_RISK_LEVEL(p_organization_id);
        
        -- Estat�sticas da organiza��o
        SELECT 
            COUNT(DISTINCT n.id),
            COUNT(DISTINCT CASE WHEN n.status = 'FULFILLED' THEN n.id END),
            COUNT(DISTINCT d.id),
            COUNT(DISTINCT CASE WHEN m.status IN ('PENDING', 'CONFIRMED') THEN m.id END)
        INTO v_total_needs, v_fulfilled_needs, v_total_donations, v_active_matches
        FROM GS_needs n
        LEFT JOIN GS_users u ON n.organization_id = u.organization_id
        LEFT JOIN GS_donations d ON u.id = d.donor_id
        LEFT JOIN GS_matches m ON n.id = m.need_id
        WHERE n.organization_id = p_organization_id;
        
        -- Calcula taxa de sucesso
        IF v_total_needs > 0 THEN
            v_success_rate := ROUND((v_fulfilled_needs / v_total_needs) * 100, 2);
        ELSE
            v_success_rate := 0;
        END IF;
        
        -- Cabe�alho do relat�rio
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('RESUMO DA ORGANIZA��O');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Nome: ' || v_org_name);
        DBMS_OUTPUT.PUT_LINE('Tipo: ' || v_org_type);
        DBMS_OUTPUT.PUT_LINE('Localiza��o: ' || v_org_location);
        DBMS_OUTPUT.PUT_LINE('Criada em: ' || TO_CHAR(v_org_created, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('N�vel de Risco: ' || v_risk_level);
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Estat�sticas principais
        DBMS_OUTPUT.PUT_LINE('ESTAT�STICAS PRINCIPAIS:');
        DBMS_OUTPUT.PUT_LINE('- Total de necessidades: ' || v_total_needs);
        DBMS_OUTPUT.PUT_LINE('- Necessidades atendidas: ' || v_fulfilled_needs);
        DBMS_OUTPUT.PUT_LINE('- Taxa de sucesso: ' || v_success_rate || '%');
        DBMS_OUTPUT.PUT_LINE('- Total de doa��es: ' || v_total_donations);
        DBMS_OUTPUT.PUT_LINE('- Matches ativos: ' || v_active_matches);
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Lista de usu�rios
        DBMS_OUTPUT.PUT_LINE('USU�RIOS DA ORGANIZA��O:');
        DBMS_OUTPUT.PUT_LINE(RPAD('Nome', 25) || RPAD('Email', 30) || RPAD('Perfil', 12) || 'Ranking');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 72, '-'));
        
        FOR user_rec IN c_org_users LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(SUBSTR(user_rec.name, 1, 24), 25) ||
                RPAD(SUBSTR(user_rec.email, 1, 29), 30) ||
                RPAD(user_rec.role, 12) ||
                user_rec.ranking
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Necessidades cr�ticas
        DBMS_OUTPUT.PUT_LINE('NECESSIDADES PRIORIT�RIAS:');
        DBMS_OUTPUT.PUT_LINE(RPAD('ID', 5) || RPAD('T�tulo', 30) || RPAD('Prioridade', 10) || 
                           RPAD('Status', 18) || 'Urg�ncia');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 68, '-'));
        
        FOR need_rec IN c_critical_needs LOOP
            EXIT WHEN c_critical_needs%ROWCOUNT > 10; -- M�ximo 10 itens
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(need_rec.id, 5) ||
                RPAD(SUBSTR(need_rec.title, 1, 29), 30) ||
                RPAD(need_rec.priority, 10) ||
                RPAD(need_rec.status, 18) ||
                need_rec.urgency_score
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Relat�rio gerado em: ' || TO_CHAR(SYSTIMESTAMP, 'DD/MM/YYYY HH24:MI:SS'));
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Organiza��o n�o encontrada (ID: ' || p_organization_id || ')');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao gerar resumo: ' || SQLERRM);
    END SP_GENERATE_ORGANIZATION_SUMMARY;

END PKG_DONATION_SYSTEM;
/

-- =====================================================
-- TRIGGERS DE AUDITORIA
-- =====================================================

-- Trigger para auditoria da tabela GS_users
CREATE OR REPLACE TRIGGER TRG_AUDIT_USERS
    AFTER INSERT OR UPDATE OR DELETE ON GS_users
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    -- Determina o tipo de opera��o
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'ID:' || :NEW.id || '|EMAIL:' || :NEW.email || '|NAME:' || :NEW.name || 
                      '|ROLE:' || :NEW.role || '|ACTIVE:' || :NEW.is_active;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'ID:' || :OLD.id || '|EMAIL:' || :OLD.email || '|NAME:' || :OLD.name || 
                      '|ROLE:' || :OLD.role || '|ACTIVE:' || :OLD.is_active;
        v_new_data := 'ID:' || :NEW.id || '|EMAIL:' || :NEW.email || '|NAME:' || :NEW.name || 
                      '|ROLE:' || :NEW.role || '|ACTIVE:' || :NEW.is_active;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'ID:' || :OLD.id || '|EMAIL:' || :OLD.email || '|NAME:' || :OLD.name || 
                      '|ROLE:' || :OLD.role || '|ACTIVE:' || :OLD.is_active;
    END IF;
    
    -- Insere registro de auditoria
    INSERT INTO GS_auditoria (
        table_name, register_id, operation_type, date_time, 
        db_user, old_data, new_data
    ) VALUES (
        'GS_USERS', 
        COALESCE(:NEW.id, :OLD.id), 
        v_operation, 
        SYSTIMESTAMP,
        USER, 
        v_old_data, 
        v_new_data
    );
END;
/

-- Trigger para auditoria da tabela GS_needs
CREATE OR REPLACE TRIGGER TRG_AUDIT_NEEDS
    AFTER INSERT OR UPDATE OR DELETE ON GS_needs
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'ID:' || :NEW.id || '|TITLE:' || :NEW.title || '|CATEGORY:' || :NEW.category || 
                      '|PRIORITY:' || :NEW.priority || '|STATUS:' || :NEW.status || '|QTY:' || :NEW.quantity;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'ID:' || :OLD.id || '|TITLE:' || :OLD.title || '|CATEGORY:' || :OLD.category || 
                      '|PRIORITY:' || :OLD.priority || '|STATUS:' || :OLD.status || '|QTY:' || :OLD.quantity;
        v_new_data := 'ID:' || :NEW.id || '|TITLE:' || :NEW.title || '|CATEGORY:' || :NEW.category || 
                      '|PRIORITY:' || :NEW.priority || '|STATUS:' || :NEW.status || '|QTY:' || :NEW.quantity;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'ID:' || :OLD.id || '|TITLE:' || :OLD.title || '|CATEGORY:' || :OLD.category || 
                      '|PRIORITY:' || :OLD.priority || '|STATUS:' || :OLD.status || '|QTY:' || :OLD.quantity;
    END IF;
    
    INSERT INTO GS_auditoria (
        table_name, register_id, operation_type, date_time, 
        db_user, old_data, new_data
    ) VALUES (
        'GS_NEEDS', 
        COALESCE(:NEW.id, :OLD.id), 
        v_operation, 
        SYSTIMESTAMP,
        USER, 
        v_old_data, 
        v_new_data
    );
END;
/

-- Trigger para auditoria da tabela GS_donations
CREATE OR REPLACE TRIGGER TRG_AUDIT_DONATIONS
    AFTER INSERT OR UPDATE OR DELETE ON GS_donations
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'ID:' || :NEW.id || '|TITLE:' || :NEW.title || '|CATEGORY:' || :NEW.category || 
                      '|STATUS:' || :NEW.status || '|QTY:' || :NEW.quantity || '|DONOR:' || :NEW.donor_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'ID:' || :OLD.id || '|TITLE:' || :OLD.title || '|CATEGORY:' || :OLD.category || 
                      '|STATUS:' || :OLD.status || '|QTY:' || :OLD.quantity || '|DONOR:' || :OLD.donor_id;
        v_new_data := 'ID:' || :NEW.id || '|TITLE:' || :NEW.title || '|CATEGORY:' || :NEW.category || 
                      '|STATUS:' || :NEW.status || '|QTY:' || :NEW.quantity || '|DONOR:' || :NEW.donor_id;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'ID:' || :OLD.id || '|TITLE:' || :OLD.title || '|CATEGORY:' || :OLD.category || 
                      '|STATUS:' || :OLD.status || '|QTY:' || :OLD.quantity || '|DONOR:' || :OLD.donor_id;
    END IF;
    
    INSERT INTO GS_auditoria (
        table_name, register_id, operation_type, date_time, 
        db_user, old_data, new_data
    ) VALUES (
        'GS_DONATIONS', 
        COALESCE(:NEW.id, :OLD.id), 
        v_operation, 
        SYSTIMESTAMP,
        USER, 
        v_old_data, 
        v_new_data
    );
END;
/

-- Trigger para auditoria da tabela GS_matches
CREATE OR REPLACE TRIGGER TRG_AUDIT_MATCHES
    AFTER INSERT OR UPDATE OR DELETE ON GS_matches
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'ID:' || :NEW.id || '|NEED_ID:' || :NEW.need_id || '|DONATION_ID:' || :NEW.donation_id || 
                      '|STATUS:' || :NEW.status || '|QTY:' || :NEW.matched_quantity || '|SCORE:' || :NEW.compatibility_score;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'ID:' || :OLD.id || '|NEED_ID:' || :OLD.need_id || '|DONATION_ID:' || :OLD.donation_id || 
                      '|STATUS:' || :OLD.status || '|QTY:' || :OLD.matched_quantity || '|SCORE:' || :OLD.compatibility_score;
        v_new_data := 'ID:' || :NEW.id || '|NEED_ID:' || :NEW.need_id || '|DONATION_ID:' || :NEW.donation_id || 
                      '|STATUS:' || :NEW.status || '|QTY:' || :NEW.matched_quantity || '|SCORE:' || :NEW.compatibility_score;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'ID:' || :OLD.id || '|NEED_ID:' || :OLD.need_id || '|DONATION_ID:' || :OLD.donation_id || 
                      '|STATUS:' || :OLD.status || '|QTY:' || :OLD.matched_quantity || '|SCORE:' || :OLD.compatibility_score;
    END IF;
    
    INSERT INTO GS_auditoria (
        table_name, register_id, operation_type, date_time, 
        db_user, old_data, new_data
    ) VALUES (
        'GS_MATCHES', 
        COALESCE(:NEW.id, :OLD.id), 
        v_operation, 
        SYSTIMESTAMP,
        USER, 
        v_old_data, 
        v_new_data
    );
END;
/

-- =====================================================
-- TRIGGERS DE VALIDA��O E REGRAS DE NEG�CIO
-- =====================================================

-- Trigger para valida��o autom�tica de necessidades
CREATE OR REPLACE TRIGGER TRG_VALIDATE_NEEDS
    BEFORE INSERT OR UPDATE ON GS_needs
    FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(20);
    v_org_active NUMBER;
BEGIN
    -- Valida se usu�rio pode criar necessidades
    SELECT role INTO v_user_role 
    FROM GS_users 
    WHERE id = :NEW.creator_id AND is_active = 'Y';
    
    IF v_user_role NOT IN ('NGO_MEMBER', 'ADMIN') THEN
        RAISE_APPLICATION_ERROR(-20100, 'Apenas membros de ONG podem criar necessidades');
    END IF;
    
    -- Valida deadline
    IF :NEW.deadline_date IS NOT NULL AND :NEW.deadline_date <= SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20101, 'Data limite deve ser futura');
    END IF;
    
    -- Valida prioridade vs prazo
    IF :NEW.priority = 'CRITICAL' AND :NEW.deadline_date > SYSTIMESTAMP + 7 THEN
        RAISE_APPLICATION_ERROR(-20102, 'Necessidade cr�tica deve ter prazo m�ximo de 7 dias');
    END IF;
    
    -- Atualiza timestamp
    :NEW.updated_at := SYSTIMESTAMP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20103, 'Usu�rio n�o encontrado ou inativo');
END;
/

-- Trigger para valida��o de doa��es
CREATE OR REPLACE TRIGGER TRG_VALIDATE_DONATIONS
    BEFORE INSERT OR UPDATE ON GS_donations
    FOR EACH ROW
DECLARE
    v_user_active CHAR(1);
BEGIN
    -- Valida se usu�rio est� ativo
    SELECT is_active INTO v_user_active 
    FROM GS_users 
    WHERE id = :NEW.donor_id;
    
    IF v_user_active = 'N' THEN
        RAISE_APPLICATION_ERROR(-20104, 'Usu�rio inativo n�o pode fazer doa��es');
    END IF;
    
    -- Valida data de validade
    IF :NEW.expiry_date IS NOT NULL AND :NEW.expiry_date <= SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20105, 'Data de validade deve ser futura');
    END IF;
    
    -- Auto-expira doa��es vencidas
    IF :NEW.expiry_date < SYSTIMESTAMP AND :NEW.status = 'AVAILABLE' THEN
        :NEW.status := 'EXPIRED';
    END IF;
    
    -- Atualiza timestamp
    :NEW.updated_at := SYSTIMESTAMP;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20106, 'Doador n�o encontrado');
END;
/
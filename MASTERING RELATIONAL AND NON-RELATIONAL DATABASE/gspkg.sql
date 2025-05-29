-- ====================================
-- PACKAGE SPECIFICATION: PKG_GS_CRUD
-- ====================================

CREATE OR REPLACE PACKAGE PKG_GS_CRUD AS

    -- Exception personalizada
    e_validation_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_validation_error, -20001);

    -- =====================================
    -- PROCEDURES PARA ORGANIZATIONS
    -- =====================================
    
    PROCEDURE SP_INSERT_ORGANIZATION(
        p_name              IN VARCHAR2,
        p_description       IN CLOB,
        p_location          IN VARCHAR2,
        p_contact_email     IN VARCHAR2 DEFAULT NULL,
        p_contact_phone     IN VARCHAR2 DEFAULT NULL,
        p_type              IN VARCHAR2 DEFAULT NULL,
        p_organization_id   OUT NUMBER
    );

    PROCEDURE SP_UPDATE_ORGANIZATION(
        p_id                IN NUMBER,
        p_name              IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_contact_email     IN VARCHAR2 DEFAULT NULL,
        p_contact_phone     IN VARCHAR2 DEFAULT NULL,
        p_type              IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE SP_DELETE_ORGANIZATION(
        p_id IN NUMBER
    );

    -- =====================================
    -- PROCEDURES PARA USERS
    -- =====================================
    
    PROCEDURE SP_INSERT_USER(
        p_email             IN VARCHAR2,
        p_phone             IN VARCHAR2 DEFAULT NULL,
        p_name              IN VARCHAR2,
        p_password_hash     IN VARCHAR2 DEFAULT NULL,
        p_role              IN VARCHAR2 DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL,
        p_user_id           OUT NUMBER
    );

    PROCEDURE SP_UPDATE_USER(
        p_id                IN NUMBER,
        p_email             IN VARCHAR2 DEFAULT NULL,
        p_phone             IN VARCHAR2 DEFAULT NULL,
        p_name              IN VARCHAR2 DEFAULT NULL,
        p_password_hash     IN VARCHAR2 DEFAULT NULL,
        p_role              IN VARCHAR2 DEFAULT NULL,
        p_is_active         IN CHAR DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL
    );

    PROCEDURE SP_DELETE_USER(
        p_id IN NUMBER
    );

    -- =====================================
    -- PROCEDURES PARA NEEDS
    -- =====================================
    
    PROCEDURE SP_INSERT_NEED(
        p_title             IN VARCHAR2,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_priority          IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_deadline_date     IN TIMESTAMP DEFAULT NULL,
        p_creator_id        IN NUMBER,
        p_organization_id   IN NUMBER DEFAULT NULL,
        p_need_id           OUT NUMBER
    );

    PROCEDURE SP_UPDATE_NEED(
        p_id                IN NUMBER,
        p_title             IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_priority          IN VARCHAR2 DEFAULT NULL,
        p_status            IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER DEFAULT NULL,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_deadline_date     IN TIMESTAMP DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL
    );

    PROCEDURE SP_DELETE_NEED(
        p_id IN NUMBER
    );

    -- =====================================
    -- PROCEDURES PARA DONATIONS
    -- =====================================
    
    PROCEDURE SP_INSERT_DONATION(
        p_title             IN VARCHAR2,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_expiry_date       IN TIMESTAMP DEFAULT NULL,
        p_donor_id          IN NUMBER,
        p_donation_id       OUT NUMBER
    );

    PROCEDURE SP_UPDATE_DONATION(
        p_id                IN NUMBER,
        p_title             IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_status            IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER DEFAULT NULL,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_expiry_date       IN TIMESTAMP DEFAULT NULL
    );

    PROCEDURE SP_DELETE_DONATION(
        p_id IN NUMBER
    );

    -- =====================================
    -- PROCEDURES PARA MATCHES
    -- =====================================
    
    PROCEDURE SP_INSERT_MATCH(
        p_need_id               IN NUMBER,
        p_donation_id           IN NUMBER,
        p_matched_quantity      IN NUMBER DEFAULT NULL,
        p_compatibility_score   IN NUMBER DEFAULT NULL,
        p_notes                 IN CLOB DEFAULT NULL,
        p_match_id              OUT NUMBER
    );

    PROCEDURE SP_UPDATE_MATCH(
        p_id                    IN NUMBER,
        p_status                IN VARCHAR2 DEFAULT NULL,
        p_matched_quantity      IN NUMBER DEFAULT NULL,
        p_compatibility_score   IN NUMBER DEFAULT NULL,
        p_notes                 IN CLOB DEFAULT NULL
    );

    PROCEDURE SP_DELETE_MATCH(
        p_id IN NUMBER
    );

    -- =====================================
    -- PROCEDURES PARA AUDITORIA
    -- =====================================
    
    PROCEDURE SP_INSERT_AUDIT(
        p_table_name        IN VARCHAR2,
        p_register_id       IN NUMBER,
        p_operation_type    IN VARCHAR2,
        p_db_user           IN VARCHAR2,
        p_old_data          IN CLOB DEFAULT NULL,
        p_new_data          IN CLOB DEFAULT NULL,
        p_audit_id          OUT NUMBER
    );

END PKG_GS_CRUD;
/

-- ====================================
-- PACKAGE BODY: PKG_GS_CRUD
-- ====================================

CREATE OR REPLACE PACKAGE BODY PKG_GS_CRUD AS

    -- =====================================
    -- PROCEDURES PARA ORGANIZATIONS
    -- =====================================
    
    PROCEDURE SP_INSERT_ORGANIZATION(
        p_name              IN VARCHAR2,
        p_description       IN CLOB,
        p_location          IN VARCHAR2,
        p_contact_email     IN VARCHAR2 DEFAULT NULL,
        p_contact_phone     IN VARCHAR2 DEFAULT NULL,
        p_type              IN VARCHAR2 DEFAULT NULL,
        p_organization_id   OUT NUMBER
    ) IS
    BEGIN
        -- Validações
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome da organização é obrigatório');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Localização é obrigatória');
        END IF;
        
        IF p_type IS NOT NULL AND p_type NOT IN ('NGO', 'CHARITY', 'GOVERNMENT', 'RELIGIOUS', 'COMMUNITY') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Tipo de organização inválido');
        END IF;

        -- Insert
        INSERT INTO GS_organizations (
            name, description, location, contact_email, 
            contact_phone, type, created_at, updated_at
        ) VALUES (
            TRIM(p_name), p_description, TRIM(p_location), p_contact_email,
            p_contact_phone, p_type, SYSTIMESTAMP, SYSTIMESTAMP
        ) RETURNING id INTO p_organization_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_ORGANIZATION;

    PROCEDURE SP_UPDATE_ORGANIZATION(
        p_id                IN NUMBER,
        p_name              IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_contact_email     IN VARCHAR2 DEFAULT NULL,
        p_contact_phone     IN VARCHAR2 DEFAULT NULL,
        p_type              IN VARCHAR2 DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
        END IF;
        
        -- Validações
        IF p_type IS NOT NULL AND p_type NOT IN ('NGO', 'CHARITY', 'GOVERNMENT', 'RELIGIOUS', 'COMMUNITY') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Tipo de organização inválido');
        END IF;

        -- Update dinâmico
        UPDATE GS_organizations 
        SET name = NVL(TRIM(p_name), name),
            description = NVL(p_description, description),
            location = NVL(TRIM(p_location), location),
            contact_email = NVL(p_contact_email, contact_email),
            contact_phone = NVL(p_contact_phone, contact_phone),
            type = NVL(p_type, type),
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_ORGANIZATION;

    PROCEDURE SP_DELETE_ORGANIZATION(
        p_id IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
        END IF;
        
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE organization_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Não é possível excluir organização com usuários vinculados');
        END IF;

        DELETE FROM GS_organizations WHERE id = p_id;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_ORGANIZATION;

    -- =====================================
    -- PROCEDURES PARA USERS
    -- =====================================
    
    PROCEDURE SP_INSERT_USER(
        p_email             IN VARCHAR2,
        p_phone             IN VARCHAR2 DEFAULT NULL,
        p_name              IN VARCHAR2,
        p_password_hash     IN VARCHAR2 DEFAULT NULL,
        p_role              IN VARCHAR2 DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL,
        p_user_id           OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validações
        IF p_email IS NULL OR TRIM(p_email) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email é obrigatório');
        END IF;
        
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome é obrigatório');
        END IF;
        
        IF p_role IS NOT NULL AND p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Role inválido');
        END IF;
        
        -- Verificar se organização existe
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
            END IF;
        END IF;

        -- Insert
        INSERT INTO GS_users (
            email, phone, name, password_hash, role, 
            organization_id, created_at, updated_at
        ) VALUES (
            LOWER(TRIM(p_email)), p_phone, TRIM(p_name), p_password_hash, p_role,
            p_organization_id, SYSTIMESTAMP, SYSTIMESTAMP
        ) RETURNING id INTO p_user_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_USER;

    PROCEDURE SP_UPDATE_USER(
        p_id                IN NUMBER,
        p_email             IN VARCHAR2 DEFAULT NULL,
        p_phone             IN VARCHAR2 DEFAULT NULL,
        p_name              IN VARCHAR2 DEFAULT NULL,
        p_password_hash     IN VARCHAR2 DEFAULT NULL,
        p_role              IN VARCHAR2 DEFAULT NULL,
        p_is_active         IN CHAR DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário não encontrado');
        END IF;
        
        -- Validações
        IF p_role IS NOT NULL AND p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Role inválido');
        END IF;
        
        IF p_is_active IS NOT NULL AND p_is_active NOT IN ('Y', 'N') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Status ativo inválido');
        END IF;
        
        -- Verificar se organização existe
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
            END IF;
        END IF;

        -- Update dinâmico
        UPDATE GS_users 
        SET email = NVL(LOWER(TRIM(p_email)), email),
            phone = NVL(p_phone, phone),
            name = NVL(TRIM(p_name), name),
            password_hash = NVL(p_password_hash, password_hash),
            role = NVL(p_role, role),
            is_active = NVL(p_is_active, is_active),
            organization_id = NVL(p_organization_id, organization_id),
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_USER;

    PROCEDURE SP_DELETE_USER(
        p_id IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário não encontrado');
        END IF;
        
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE creator_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Não é possível excluir usuário com necessidades criadas');
        END IF;
        
        SELECT COUNT(*) INTO v_count FROM GS_donations WHERE donor_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Não é possível excluir usuário com doações realizadas');
        END IF;

        DELETE FROM GS_users WHERE id = p_id;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_USER;

    -- =====================================
    -- PROCEDURES PARA NEEDS
    -- =====================================
    
    PROCEDURE SP_INSERT_NEED(
        p_title             IN VARCHAR2,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_priority          IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_deadline_date     IN TIMESTAMP DEFAULT NULL,
        p_creator_id        IN NUMBER,
        p_organization_id   IN NUMBER DEFAULT NULL,
        p_need_id           OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validações
        IF p_title IS NULL OR TRIM(p_title) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Título é obrigatório');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Localização é obrigatória');
        END IF;
        
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Quantidade deve ser maior que zero');
        END IF;
        
        IF p_priority IS NOT NULL AND p_priority NOT IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Prioridade inválida');
        END IF;
        
        -- Verificar se creator existe
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE id = p_creator_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário criador não encontrado');
        END IF;
        
        -- Verificar se organização existe
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
            END IF;
        END IF;

        -- Insert
        INSERT INTO GS_needs (
            title, description, location, category, priority, status,
            quantity, unit, deadline_date, creator_id, organization_id,
            created_at, updated_at
        ) VALUES (
            TRIM(p_title), p_description, TRIM(p_location), p_category, p_priority, 'ACTIVE',
            p_quantity, p_unit, p_deadline_date, p_creator_id, p_organization_id,
            SYSTIMESTAMP, SYSTIMESTAMP
        ) RETURNING id INTO p_need_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_NEED;

    PROCEDURE SP_UPDATE_NEED(
        p_id                IN NUMBER,
        p_title             IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_priority          IN VARCHAR2 DEFAULT NULL,
        p_status            IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER DEFAULT NULL,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_deadline_date     IN TIMESTAMP DEFAULT NULL,
        p_organization_id   IN NUMBER DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Necessidade não encontrada');
        END IF;
        
        -- Validações
        IF p_priority IS NOT NULL AND p_priority NOT IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Prioridade inválida');
        END IF;
        
        IF p_status IS NOT NULL AND p_status NOT IN ('ACTIVE', 'PARTIALLY_FULFILLED', 'FULFILLED', 'EXPIRED', 'CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Status inválido');
        END IF;
        
        IF p_quantity IS NOT NULL AND p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Quantidade deve ser maior que zero');
        END IF;
        
        -- Verificar se organização existe
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Organização não encontrada');
            END IF;
        END IF;

        -- Update dinâmico
        UPDATE GS_needs 
        SET title = NVL(TRIM(p_title), title),
            description = NVL(p_description, description),
            location = NVL(TRIM(p_location), location),
            category = NVL(p_category, category),
            priority = NVL(p_priority, priority),
            status = NVL(p_status, status),
            quantity = NVL(p_quantity, quantity),
            unit = NVL(p_unit, unit),
            deadline_date = NVL(p_deadline_date, deadline_date),
            organization_id = NVL(p_organization_id, organization_id),
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_NEED;

    PROCEDURE SP_DELETE_NEED(
        p_id IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Necessidade não encontrada');
        END IF;
        
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_matches WHERE need_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Não é possível excluir necessidade com matches vinculados');
        END IF;

        DELETE FROM GS_needs WHERE id = p_id;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_NEED;

    -- =====================================
    -- PROCEDURES PARA DONATIONS
    -- =====================================
    
    PROCEDURE SP_INSERT_DONATION(
        p_title             IN VARCHAR2,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_expiry_date       IN TIMESTAMP DEFAULT NULL,
        p_donor_id          IN NUMBER,
        p_donation_id       OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validações
        IF p_title IS NULL OR TRIM(p_title) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Título é obrigatório');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Localização é obrigatória');
        END IF;
        
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Quantidade deve ser maior que zero');
        END IF;
        
        -- Verificar se doador existe
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE id = p_donor_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário doador não encontrado');
        END IF;

        -- Insert
        INSERT INTO GS_donations (
            title, description, location, category, quantity, unit,
            expiry_date, donor_id, created_at, updated_at
        ) VALUES (
            TRIM(p_title), p_description, TRIM(p_location), p_category, p_quantity, p_unit,
            p_expiry_date, p_donor_id, SYSTIMESTAMP, SYSTIMESTAMP
        ) RETURNING id INTO p_donation_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_DONATION;

    PROCEDURE SP_UPDATE_DONATION(
        p_id                IN NUMBER,
        p_title             IN VARCHAR2 DEFAULT NULL,
        p_description       IN CLOB DEFAULT NULL,
        p_location          IN VARCHAR2 DEFAULT NULL,
        p_category          IN VARCHAR2 DEFAULT NULL,
        p_status            IN VARCHAR2 DEFAULT NULL,
        p_quantity          IN NUMBER DEFAULT NULL,
        p_unit              IN VARCHAR2 DEFAULT NULL,
        p_expiry_date       IN TIMESTAMP DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_donations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Doação não encontrada');
        END IF;
        
        -- Validações
        IF p_status IS NOT NULL AND p_status NOT IN ('AVAILABLE', 'RESERVED', 'DONATED', 'EXPIRED') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Status inválido');
        END IF;
        
        IF p_quantity IS NOT NULL AND p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Quantidade deve ser maior que zero');
        END IF;

        -- Update dinâmico
        UPDATE GS_donations 
        SET title = NVL(TRIM(p_title), title),
            description = NVL(p_description, description),
            location = NVL(TRIM(p_location), location),
            category = NVL(p_category, category),
            status = NVL(p_status, status),
            quantity = NVL(p_quantity, quantity),
            unit = NVL(p_unit, unit),
            expiry_date = NVL(p_expiry_date, expiry_date),
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_DONATION;

    PROCEDURE SP_DELETE_DONATION(
        p_id IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_donations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Doação não encontrada');
        END IF;
        
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_matches WHERE donation_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Não é possível excluir doação com matches vinculados');
        END IF;

        DELETE FROM GS_donations WHERE id = p_id;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_DONATION;

    -- =====================================
    -- PROCEDURES PARA MATCHES
    -- =====================================
    
    PROCEDURE SP_INSERT_MATCH(
        p_need_id               IN NUMBER,
        p_donation_id           IN NUMBER,
        p_matched_quantity      IN NUMBER DEFAULT NULL,
        p_compatibility_score   IN NUMBER DEFAULT NULL,
        p_notes                 IN CLOB DEFAULT NULL,
        p_match_id              OUT NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Validações
        IF p_matched_quantity IS NOT NULL AND p_matched_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Quantidade matched deve ser maior que zero');
        END IF;
        
        IF p_compatibility_score IS NOT NULL AND (p_compatibility_score < 0 OR p_compatibility_score > 1) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Score de compatibilidade deve estar entre 0 e 1');
        END IF;

        -- Update dinâmico
        UPDATE GS_matches 
        SET status = NVL(p_status, status),
            matched_quantity = NVL(p_matched_quantity, matched_quantity),
            compatibility_score = NVL(p_compatibility_score, compatibility_score),
            notes = NVL(p_notes, notes),
            updated_at = SYSTIMESTAMP,
            confirmed_at = CASE WHEN p_status = 'CONFIRMED' THEN SYSTIMESTAMP ELSE confirmed_at END
        WHERE id = p_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_UPDATE_MATCH;

    PROCEDURE SP_DELETE_MATCH(
        p_id IN NUMBER
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_matches WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Match não encontrado');
        END IF;

        DELETE FROM GS_matches WHERE id = p_id;
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_DELETE_MATCH;

    -- =====================================
    -- PROCEDURES PARA AUDITORIA
    -- =====================================
    
    PROCEDURE SP_INSERT_AUDIT(
        p_table_name        IN VARCHAR2,
        p_register_id       IN NUMBER,
        p_operation_type    IN VARCHAR2,
        p_db_user           IN VARCHAR2,
        p_old_data          IN CLOB DEFAULT NULL,
        p_new_data          IN CLOB DEFAULT NULL,
        p_audit_id          OUT NUMBER
    ) IS
    BEGIN
        -- Validações
        IF p_table_name IS NULL OR TRIM(p_table_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome da tabela é obrigatório');
        END IF;
        
        IF p_register_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'ID do registro é obrigatório');
        END IF;
        
        IF p_operation_type IS NULL OR p_operation_type NOT IN ('INSERT', 'UPDATE', 'DELETE') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Tipo de operação inválido');
        END IF;
        
        IF p_db_user IS NULL OR TRIM(p_db_user) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuário do banco é obrigatório');
        END IF;

        -- Insert
        INSERT INTO GS_auditoria (
            table_name, register_id, operation_type, date_time,
            db_user, old_data, new_data
        ) VALUES (
            UPPER(TRIM(p_table_name)), p_register_id, UPPER(p_operation_type), SYSTIMESTAMP,
            TRIM(p_db_user), p_old_data, p_new_data
        ) RETURNING id INTO p_audit_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_INSERT_AUDIT;

END PKG_GS_CRUD;
/

-- ====================================
-- EXEMPLOS DE USO DO PACKAGE
-- ====================================

/*
-- Exemplo 1: Inserir uma organização
DECLARE
    v_org_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_ORGANIZATION(
        p_name => 'ONG Esperança',
        p_description => 'Organização focada em ajuda humanitária',
        p_location => 'São Paulo, SP',
        p_contact_email => 'contato@esperanca.org.br',
        p_contact_phone => '(11) 1234-5678',
        p_type => 'NGO',
        p_organization_id => v_org_id
    );
    DBMS_OUTPUT.PUT_LINE('Organização criada com ID: ' || v_org_id);
END;
/

-- Exemplo 2: Inserir um usuário
DECLARE
    v_user_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_USER(
        p_email => 'joao@exemplo.com',
        p_phone => '(11) 9876-5432',
        p_name => 'João Silva',
        p_role => 'DONOR',
        p_organization_id => 1,
        p_user_id => v_user_id
    );
    DBMS_OUTPUT.PUT_LINE('Usuário criado com ID: ' || v_user_id);
END;
/

-- Exemplo 3: Inserir uma necessidade
DECLARE
    v_need_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_NEED(
        p_title => 'Cestas Básicas Urgente',
        p_description => 'Necessitamos de cestas básicas para famílias carentes',
        p_location => 'São Paulo, SP - Zona Leste',
        p_category => 'FOOD',
        p_priority => 'HIGH',
        p_quantity => 50,
        p_unit => 'cestas',
        p_deadline_date => SYSTIMESTAMP + INTERVAL '30' DAY,
        p_creator_id => 1,
        p_organization_id => 1,
        p_need_id => v_need_id
    );
    DBMS_OUTPUT.PUT_LINE('Necessidade criada com ID: ' || v_need_id);
END;
/

-- Exemplo 4: Inserir uma doação
DECLARE
    v_donation_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_DONATION(
        p_title => 'Doação de Alimentos',
        p_description => 'Alimentos não perecíveis disponíveis para doação',
        p_location => 'São Paulo, SP - Centro',
        p_category => 'FOOD',
        p_quantity => 30,
        p_unit => 'cestas',
        p_expiry_date => SYSTIMESTAMP + INTERVAL '60' DAY,
        p_donor_id => 1,
        p_donation_id => v_donation_id
    );
    DBMS_OUTPUT.PUT_LINE('Doação criada com ID: ' || v_donation_id);
END;
/

-- Exemplo 5: Criar um match
DECLARE
    v_match_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_MATCH(
        p_need_id => 1,
        p_donation_id => 1,
        p_matched_quantity => 25,
        p_compatibility_score => 0.85,
        p_notes => 'Match criado automaticamente pelo sistema',
        p_match_id => v_match_id
    );
    DBMS_OUTPUT.PUT_LINE('Match criado com ID: ' || v_match_id);
END;
/

-- Exemplo 6: Atualizar status de um match
BEGIN
    PKG_GS_CRUD.SP_UPDATE_MATCH(
        p_id => 1,
        p_status => 'CONFIRMED',
        p_notes => 'Match confirmado pelas partes'
    );
    DBMS_OUTPUT.PUT_LINE('Match atualizado com sucesso');
END;
/

-- Exemplo 7: Inserir registro de auditoria
DECLARE
    v_audit_id NUMBER;
BEGIN
    PKG_GS_CRUD.SP_INSERT_AUDIT(
        p_table_name => 'GS_MATCHES',
        p_register_id => 1,
        p_operation_type => 'UPDATE',
        p_db_user => USER,
        p_old_data => '{"status":"PENDING"}',
        p_new_data => '{"status":"CONFIRMED"}',
        p_audit_id => v_audit_id
    );
    DBMS_OUTPUT.PUT_LINE('Auditoria criada com ID: ' || v_audit_id);
END;
/

-- Exemplo 8: Tratamento de erro
BEGIN
    PKG_GS_CRUD.SP_DELETE_USER(999); -- ID inexistente
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/
*/
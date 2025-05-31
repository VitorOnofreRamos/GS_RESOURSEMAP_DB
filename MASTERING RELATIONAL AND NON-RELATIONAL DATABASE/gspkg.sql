-- =====================================================
-- PACKAGE SPECIFICATION
-- =====================================================
CREATE OR REPLACE PACKAGE GS_MANAGEMENT_PKG AS

    -- ==============================================
    -- ORGANIZATIONS PROCEDURES
    -- ==============================================
    
    -- Insert Organization
    PROCEDURE INSERT_ORGANIZATION(
        p_name                  GS_organizations.name%TYPE,
        p_description           GS_organizations.description%TYPE DEFAULT NULL,
        p_location              GS_organizations.location%TYPE,
        p_contact_email         GS_organizations.contact_email%TYPE DEFAULT NULL,
        p_contact_phone         GS_organizations.contact_phone%TYPE DEFAULT NULL,
        p_type                  GS_organizations.type%TYPE DEFAULT NULL
    );
    
    -- Update Organization
    PROCEDURE UPDATE_ORGANIZATION(
        p_id                    GS_organizations.id%TYPE,
        p_name                  GS_organizations.name%TYPE DEFAULT NULL,
        p_description           GS_organizations.description%TYPE DEFAULT NULL,
        p_location              GS_organizations.location%TYPE DEFAULT NULL,
        p_contact_email         GS_organizations.contact_email%TYPE DEFAULT NULL,
        p_contact_phone         GS_organizations.contact_phone%TYPE DEFAULT NULL,
        p_type                  GS_organizations.type%TYPE DEFAULT NULL
    );
    
    -- Delete Organization
    PROCEDURE DELETE_ORGANIZATION(p_id GS_organizations.id%TYPE);
    
    -- ==============================================
    -- USERS PROCEDURES
    -- ==============================================
    
    -- Insert User
    PROCEDURE INSERT_USER(
        p_email                 GS_users.email%TYPE,
        p_phone                 GS_users.phone%TYPE DEFAULT NULL,
        p_name                  GS_users.name%TYPE,
        p_password_hash         GS_users.password_hash%TYPE DEFAULT NULL,
        p_role                  GS_users.role%TYPE,
        p_is_active             GS_users.is_active%TYPE DEFAULT 'Y',
        p_organization_id       GS_users.organization_id%TYPE DEFAULT NULL
    );
    
    -- Update User
    PROCEDURE UPDATE_USER(
        p_id                    GS_users.id%TYPE,
        p_email                 GS_users.email%TYPE DEFAULT NULL,
        p_phone                 GS_users.phone%TYPE DEFAULT NULL,
        p_name                  GS_users.name%TYPE DEFAULT NULL,
        p_password_hash         GS_users.password_hash%TYPE DEFAULT NULL,
        p_role                  GS_users.role%TYPE DEFAULT NULL,
        p_is_active             GS_users.is_active%TYPE DEFAULT NULL,
        p_last_login            GS_users.last_login%TYPE DEFAULT NULL,
        p_organization_id       GS_users.organization_id%TYPE DEFAULT NULL
    );
    
    -- Delete User
    PROCEDURE DELETE_USER(p_id GS_users.id%TYPE);
    
    -- ==============================================
    -- NEEDS PROCEDURES
    -- ==============================================
    
    -- Insert Need
    PROCEDURE INSERT_NEED(
        p_title                 GS_needs.title%TYPE,
        p_description           GS_needs.description%TYPE DEFAULT NULL,
        p_location              GS_needs.location%TYPE,
        p_category              GS_needs.category%TYPE DEFAULT NULL,
        p_priority              GS_needs.priority%TYPE DEFAULT 'MEDIUM',
        p_status                GS_needs.status%TYPE DEFAULT 'ACTIVE',
        p_quantity              GS_needs.quantity%TYPE,
        p_unit                  GS_needs.unit%TYPE DEFAULT NULL,
        p_deadline_date         GS_needs.deadline_date%TYPE DEFAULT NULL,
        p_creator_id            GS_needs.creator_id%TYPE,
        p_organization_id       GS_needs.organization_id%TYPE DEFAULT NULL
    );
    
    -- Update Need
    PROCEDURE UPDATE_NEED(
        p_id                    GS_needs.id%TYPE,
        p_title                 GS_needs.title%TYPE DEFAULT NULL,
        p_description           GS_needs.description%TYPE DEFAULT NULL,
        p_location              GS_needs.location%TYPE DEFAULT NULL,
        p_category              GS_needs.category%TYPE DEFAULT NULL,
        p_priority              GS_needs.priority%TYPE DEFAULT NULL,
        p_status                GS_needs.status%TYPE DEFAULT NULL,
        p_quantity              GS_needs.quantity%TYPE DEFAULT NULL,
        p_unit                  GS_needs.unit%TYPE DEFAULT NULL,
        p_deadline_date         GS_needs.deadline_date%TYPE DEFAULT NULL,
        p_organization_id       GS_needs.organization_id%TYPE DEFAULT NULL
    );
    
    -- Delete Need
    PROCEDURE DELETE_NEED(p_id GS_needs.id%TYPE);-- ==============================================
    -- DONATIONS PROCEDURES
    -- ==============================================
    
    -- Insert Donation
    PROCEDURE INSERT_DONATION(
        p_title                 GS_donations.title%TYPE,
        p_description           GS_donations.description%TYPE DEFAULT NULL,
        p_location              GS_donations.location%TYPE,
        p_category              GS_donations.category%TYPE DEFAULT NULL,
        p_status                GS_donations.status%TYPE DEFAULT 'AVAILABLE',
        p_quantity              GS_donations.quantity%TYPE,
        p_unit                  GS_donations.unit%TYPE DEFAULT NULL,
        p_expiry_date           GS_donations.expiry_date%TYPE DEFAULT NULL,
        p_donor_id              GS_donations.donor_id%TYPE
    );
    
    -- Update Donation
    PROCEDURE UPDATE_DONATION(
        p_id                    GS_donations.id%TYPE,
        p_title                 GS_donations.title%TYPE DEFAULT NULL,
        p_description           GS_donations.description%TYPE DEFAULT NULL,
        p_location              GS_donations.location%TYPE DEFAULT NULL,
        p_category              GS_donations.category%TYPE DEFAULT NULL,
        p_status                GS_donations.status%TYPE DEFAULT NULL,
        p_quantity              GS_donations.quantity%TYPE DEFAULT NULL,
        p_unit                  GS_donations.unit%TYPE DEFAULT NULL,
        p_expiry_date           GS_donations.expiry_date%TYPE DEFAULT NULL
    );
    
    -- Delete Donation
    PROCEDURE DELETE_DONATION(p_id GS_donations.id%TYPE);
    
    -- ==============================================
    -- MATCHES PROCEDURES
    -- ==============================================
    
    -- Insert Match
    PROCEDURE INSERT_MATCH(
        p_need_id               GS_matches.need_id%TYPE,
        p_donation_id           GS_matches.donation_id%TYPE,
        p_status                GS_matches.status%TYPE DEFAULT 'PENDING',
        p_matched_quantity      GS_matches.matched_quantity%TYPE DEFAULT NULL,
        p_compatibility_score   GS_matches.compatibility_score%TYPE DEFAULT NULL,
        p_notes                 GS_matches.notes%TYPE DEFAULT NULL
    );
    
    -- Update Match
    PROCEDURE UPDATE_MATCH(
        p_id                    GS_matches.id%TYPE,
        p_status                GS_matches.status%TYPE DEFAULT NULL,
        p_matched_quantity      GS_matches.matched_quantity%TYPE DEFAULT NULL,
        p_compatibility_score   GS_matches.compatibility_score%TYPE DEFAULT NULL,
        p_confirmed_at          GS_matches.confirmed_at%TYPE DEFAULT NULL,
        p_notes                 GS_matches.notes%TYPE DEFAULT NULL
    );
    
    -- Delete Match
    PROCEDURE DELETE_MATCH(p_id GS_matches.id%TYPE);    
    
END GS_MANAGEMENT_PKG;
/

-- =====================================================
-- PACKAGE BODY
-- =====================================================
CREATE OR REPLACE PACKAGE BODY GS_MANAGEMENT_PKG AS

    -- ==============================================
    -- ORGANIZATIONS PROCEDURES IMPLEMENTATION
    -- ==============================================
    
    PROCEDURE INSERT_ORGANIZATION(
        p_name                  GS_organizations.name%TYPE,
        p_description           GS_organizations.description%TYPE DEFAULT NULL,
        p_location              GS_organizations.location%TYPE,
        p_contact_email         GS_organizations.contact_email%TYPE DEFAULT NULL,
        p_contact_phone         GS_organizations.contact_phone%TYPE DEFAULT NULL,
        p_type                  GS_organizations.type%TYPE DEFAULT NULL
    ) IS
    BEGIN
        -- Valida��es b�sicas
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome da organiza��o � obrigat�rio');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Localiza��o � obrigat�ria');
        END IF;
        
        INSERT INTO GS_organizations (
            name, description, location, contact_email, 
            contact_phone, type, created_at
        ) VALUES (
            TRIM(p_name), p_description, TRIM(p_location), 
            p_contact_email, p_contact_phone, p_type, SYSTIMESTAMP
        );
        
        DBMS_OUTPUT.PUT_LINE('Organiza��o inserida com sucesso. ID: ' || seq_organizations.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir organiza��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END INSERT_ORGANIZATION;
    
    PROCEDURE UPDATE_ORGANIZATION(
        p_id                    GS_organizations.id%TYPE,
        p_name                  GS_organizations.name%TYPE DEFAULT NULL,
        p_description           GS_organizations.description%TYPE DEFAULT NULL,
        p_location              GS_organizations.location%TYPE DEFAULT NULL,
        p_contact_email         GS_organizations.contact_email%TYPE DEFAULT NULL,
        p_contact_phone         GS_organizations.contact_phone%TYPE DEFAULT NULL,
        p_type                  GS_organizations.type%TYPE DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_organizations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Organiza��o n�o encontrada');
        END IF;
        
        -- Validar tipo se fornecido
        IF p_type IS NOT NULL AND p_type NOT IN ('NGO', 'CHARITY', 'GOVERNMENT', 'RELIGIOUS', 'COMMUNITY') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Tipo de organiza��o inv�lido');
        END IF;
        
        UPDATE GS_organizations
        SET 
            name = CASE WHEN p_name IS NOT NULL THEN TRIM(p_name) ELSE name END,
            description = CASE WHEN p_description IS NOT NULL THEN p_description ELSE description END,
            location = CASE WHEN p_location IS NOT NULL THEN TRIM(p_location) ELSE location END,
            contact_email = CASE WHEN p_contact_email IS NOT NULL THEN p_contact_email ELSE contact_email END,
            contact_phone = CASE WHEN p_contact_phone IS NOT NULL THEN p_contact_phone ELSE contact_phone END,
            type = CASE WHEN p_type IS NOT NULL THEN p_type ELSE type END
        WHERE id = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Organiza��o atualizada com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar organiza��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Update_Organization;
    
    PROCEDURE Delete_Organization(p_id GS_organizations.id%TYPE) IS
        v_count NUMBER;
    BEGIN
        -- Verificar depend�ncias
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE organization_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Organiza��o possui usu�rios vinculados');
        END IF;
        
        DELETE FROM GS_organizations WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Organiza��o deletada com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Organiza��o n�o encontrada.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar organiza��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Delete_Organization;
    
    -- ==============================================
    -- USERS PROCEDURES IMPLEMENTATION
    -- ==============================================
    
    PROCEDURE Insert_User(
        p_email                 GS_users.email%TYPE,
        p_phone                 GS_users.phone%TYPE DEFAULT NULL,
        p_name                  GS_users.name%TYPE,
        p_password_hash         GS_users.password_hash%TYPE DEFAULT NULL,
        p_role                  GS_users.role%TYPE,
        p_is_active             GS_users.is_active%TYPE DEFAULT 'Y',
        p_organization_id       GS_users.organization_id%TYPE DEFAULT NULL
    ) IS
        v_org_count NUMBER;
    BEGIN
        -- Valida��es b�sicas
        IF p_email IS NULL OR TRIM(p_email) = '' THEN
            RAISE_APPLICATION_ERROR(-20101, 'Email � obrigat�rio');
        END IF;
        
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20102, 'Nome � obrigat�rio');
        END IF;
        
        IF p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20103, 'Role inv�lido');
        END IF;
        
        -- Verificar organiza��o se fornecida
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_org_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20105, 'Organiza��o n�o encontrada');
            END IF;
        END IF;
        
        INSERT INTO GS_users (
            email, phone, name, password_hash, role, 
            is_active, created_at, organization_id
        ) VALUES (
            LOWER(TRIM(p_email)), p_phone, TRIM(p_name), 
            p_password_hash, p_role, p_is_active, 
            SYSTIMESTAMP, p_organization_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Usu�rio inserido com sucesso. ID: ' || seq_users.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: Email j� existe');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir usu�rio: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Insert_User;
    
    PROCEDURE Update_User(
        p_id                    GS_users.id%TYPE,
        p_email                 GS_users.email%TYPE DEFAULT NULL,
        p_phone                 GS_users.phone%TYPE DEFAULT NULL,
        p_name                  GS_users.name%TYPE DEFAULT NULL,
        p_password_hash         GS_users.password_hash%TYPE DEFAULT NULL,
        p_role                  GS_users.role%TYPE DEFAULT NULL,
        p_is_active             GS_users.is_active%TYPE DEFAULT NULL,
        p_last_login            GS_users.last_login%TYPE DEFAULT NULL,
        p_organization_id       GS_users.organization_id%TYPE DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se existe
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20106, 'Usu�rio n�o encontrado');
        END IF;
        
        -- Validar role se fornecido
        IF p_role IS NOT NULL AND p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20103, 'Role inv�lido');
        END IF;
        
        UPDATE GS_users
        SET 
            email = CASE WHEN p_email IS NOT NULL THEN LOWER(TRIM(p_email)) ELSE email END,
            phone = CASE WHEN p_phone IS NOT NULL THEN p_phone ELSE phone END,
            name = CASE WHEN p_name IS NOT NULL THEN TRIM(p_name) ELSE name END,
            password_hash = CASE WHEN p_password_hash IS NOT NULL THEN p_password_hash ELSE password_hash END,
            role = CASE WHEN p_role IS NOT NULL THEN p_role ELSE role END,
            is_active = CASE WHEN p_is_active IS NOT NULL THEN p_is_active ELSE is_active END,
            last_login = CASE WHEN p_last_login IS NOT NULL THEN p_last_login ELSE last_login END,
            organization_id = CASE WHEN p_organization_id IS NOT NULL THEN p_organization_id ELSE organization_id END
        WHERE id = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Usu�rio atualizado com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar usu�rio: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Update_User;
    
    PROCEDURE Delete_User(p_id GS_users.id%TYPE) IS
        v_count NUMBER;
    BEGIN
        -- Verificar depend�ncias
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE creator_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20107, 'Usu�rio possui necessidades vinculadas');
        END IF;
        
        DELETE FROM GS_users WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Usu�rio deletado com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Usu�rio n�o encontrado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar usu�rio: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Delete_User;
    
    -- ==============================================
    -- NEEDS PROCEDURES IMPLEMENTATION
    -- ==============================================
    
    PROCEDURE INSERT_NEED(
        p_title                 GS_needs.title%TYPE,
        p_description           GS_needs.description%TYPE DEFAULT NULL,
        p_location              GS_needs.location%TYPE,
        p_category              GS_needs.category%TYPE DEFAULT NULL,
        p_priority              GS_needs.priority%TYPE DEFAULT 'MEDIUM',
        p_status                GS_needs.status%TYPE DEFAULT 'ACTIVE',
        p_quantity              GS_needs.quantity%TYPE,
        p_unit                  GS_needs.unit%TYPE DEFAULT NULL,
        p_deadline_date         GS_needs.deadline_date%TYPE DEFAULT NULL,
        p_creator_id            GS_needs.creator_id%TYPE,
        p_organization_id       GS_needs.organization_id%TYPE DEFAULT NULL
    ) IS
        v_user_count NUMBER;
        v_org_count NUMBER;
    BEGIN
        -- Valida��es b�sicas
        IF p_title IS NULL OR TRIM(p_title) = '' THEN
            RAISE_APPLICATION_ERROR(-20201, 'T�tulo da necessidade � obrigat�rio');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20202, 'Localiza��o � obrigat�ria');
        END IF;
        
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20203, 'Quantidade deve ser maior que zero');
        END IF;
        
        IF p_creator_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20204, 'ID do criador � obrigat�rio');
        END IF;
        
        -- Validar categoria se fornecida
        IF p_category IS NOT NULL AND p_category NOT IN ('FOOD', 'WATER', 'CLOTHING', 'MEDICAL', 'SHELTER', 'EDUCATION', 'TRANSPORTATION', 'OTHER') THEN
            RAISE_APPLICATION_ERROR(-20205, 'Categoria inv�lida');
        END IF;
        
        -- Validar prioridade
        IF p_priority NOT IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') THEN
            RAISE_APPLICATION_ERROR(-20206, 'Prioridade inv�lida');
        END IF;
        
        -- Validar status
        IF p_status NOT IN ('ACTIVE', 'PARTIALLY_FULFILLED', 'FULFILLED', 'EXPIRED', 'CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20207, 'Status inv�lido');
        END IF;
        
        -- Verificar se usu�rio criador existe
        SELECT COUNT(*) INTO v_user_count FROM GS_users WHERE id = p_creator_id;
        IF v_user_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20208, 'Usu�rio criador n�o encontrado');
        END IF;
        
        -- Verificar organiza��o se fornecida
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_org_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20209, 'Organiza��o n�o encontrada');
            END IF;
        END IF;
        
        -- Validar data limite se fornecida
        IF p_deadline_date IS NOT NULL AND p_deadline_date <= SYSTIMESTAMP THEN
            RAISE_APPLICATION_ERROR(-20210, 'Data limite deve ser futura');
        END IF;
        
        INSERT INTO GS_needs (
            title, description, location, category, priority, 
            status, quantity, unit, deadline_date, created_at, 
            creator_id, organization_id
        ) VALUES (
            TRIM(p_title), p_description, TRIM(p_location), p_category, 
            p_priority, p_status, p_quantity, p_unit, p_deadline_date, 
            SYSTIMESTAMP, p_creator_id, p_organization_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Necessidade inserida com sucesso. ID: ' || seq_needs.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir necessidade: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END INSERT_NEED;
    
    PROCEDURE UPDATE_NEED(
        p_id                    GS_needs.id%TYPE,
        p_title                 GS_needs.title%TYPE DEFAULT NULL,
        p_description           GS_needs.description%TYPE DEFAULT NULL,
        p_location              GS_needs.location%TYPE DEFAULT NULL,
        p_category              GS_needs.category%TYPE DEFAULT NULL,
        p_priority              GS_needs.priority%TYPE DEFAULT NULL,
        p_status                GS_needs.status%TYPE DEFAULT NULL,
        p_quantity              GS_needs.quantity%TYPE DEFAULT NULL,
        p_unit                  GS_needs.unit%TYPE DEFAULT NULL,
        p_deadline_date         GS_needs.deadline_date%TYPE DEFAULT NULL,
        p_organization_id       GS_needs.organization_id%TYPE DEFAULT NULL
    ) IS
        v_count NUMBER;
        v_org_count NUMBER;
    BEGIN
        -- Verificar se necessidade existe
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20211, 'Necessidade n�o encontrada');
        END IF;
        
        -- Validar categoria se fornecida
        IF p_category IS NOT NULL AND p_category NOT IN ('FOOD', 'WATER', 'CLOTHING', 'MEDICAL', 'SHELTER', 'EDUCATION', 'TRANSPORTATION', 'OTHER') THEN
            RAISE_APPLICATION_ERROR(-20205, 'Categoria inv�lida');
        END IF;
        
        -- Validar prioridade se fornecida
        IF p_priority IS NOT NULL AND p_priority NOT IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') THEN
            RAISE_APPLICATION_ERROR(-20206, 'Prioridade inv�lida');
        END IF;
        
        -- Validar status se fornecido
        IF p_status IS NOT NULL AND p_status NOT IN ('ACTIVE', 'PARTIALLY_FULFILLED', 'FULFILLED', 'EXPIRED', 'CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20207, 'Status inv�lido');
        END IF;
        
        -- Validar quantidade se fornecida
        IF p_quantity IS NOT NULL AND p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20203, 'Quantidade deve ser maior que zero');
        END IF;
        
        -- Verificar organiza��o se fornecida
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_org_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20209, 'Organiza��o n�o encontrada');
            END IF;
        END IF;
        
        -- Validar data limite se fornecida
        IF p_deadline_date IS NOT NULL AND p_deadline_date <= SYSTIMESTAMP THEN
            RAISE_APPLICATION_ERROR(-20210, 'Data limite deve ser futura');
        END IF;
        
        UPDATE GS_needs
        SET 
            title = CASE WHEN p_title IS NOT NULL THEN TRIM(p_title) ELSE title END,
            description = CASE WHEN p_description IS NOT NULL THEN p_description ELSE description END,
            location = CASE WHEN p_location IS NOT NULL THEN TRIM(p_location) ELSE location END,
            category = CASE WHEN p_category IS NOT NULL THEN p_category ELSE category END,
            priority = CASE WHEN p_priority IS NOT NULL THEN p_priority ELSE priority END,
            status = CASE WHEN p_status IS NOT NULL THEN p_status ELSE status END,
            quantity = CASE WHEN p_quantity IS NOT NULL THEN p_quantity ELSE quantity END,
            unit = CASE WHEN p_unit IS NOT NULL THEN p_unit ELSE unit END,
            deadline_date = CASE WHEN p_deadline_date IS NOT NULL THEN p_deadline_date ELSE deadline_date END,
            organization_id = CASE WHEN p_organization_id IS NOT NULL THEN p_organization_id ELSE organization_id END,
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Necessidade atualizada com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar necessidade: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END UPDATE_NEED;
    
    PROCEDURE DELETE_NEED(p_id GS_needs.id%TYPE) IS
        v_count NUMBER;
        v_matches_count NUMBER;
    BEGIN
        -- Verificar se necessidade existe
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20211, 'Necessidade n�o encontrada');
        END IF;
        
        -- Verificar depend�ncias (matches)
        SELECT COUNT(*) INTO v_matches_count FROM GS_matches WHERE need_id = p_id;
        IF v_matches_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20212, 'Necessidade possui matches vinculados');
        END IF;
        
        DELETE FROM GS_needs WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Necessidade deletada com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Necessidade n�o encontrada.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar necessidade: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END DELETE_NEED;
    
    -- ==============================================
    -- DONATIONS PROCEDURES IMPLEMENTATION
    -- ==============================================
    
    PROCEDURE INSERT_DONATION(
        p_title                 GS_donations.title%TYPE,
        p_description           GS_donations.description%TYPE DEFAULT NULL,
        p_location              GS_donations.location%TYPE,
        p_category              GS_donations.category%TYPE DEFAULT NULL,
        p_status                GS_donations.status%TYPE DEFAULT 'AVAILABLE',
        p_quantity              GS_donations.quantity%TYPE,
        p_unit                  GS_donations.unit%TYPE DEFAULT NULL,
        p_expiry_date           GS_donations.expiry_date%TYPE DEFAULT NULL,
        p_donor_id              GS_donations.donor_id%TYPE
    ) IS
        v_donor_count NUMBER;
    BEGIN
        -- Valida��es b�sicas
        IF p_title IS NULL OR TRIM(p_title) = '' THEN
            RAISE_APPLICATION_ERROR(-20301, 'T�tulo da doa��o � obrigat�rio');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20302, 'Localiza��o � obrigat�ria');
        END IF;
        
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20303, 'Quantidade deve ser maior que zero');
        END IF;
        
        IF p_donor_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20304, 'ID do doador � obrigat�rio');
        END IF;
        
        -- Validar categoria se fornecida
        IF p_category IS NOT NULL AND p_category NOT IN ('FOOD', 'WATER', 'CLOTHING', 'MEDICAL', 'SHELTER', 'EDUCATION', 'TRANSPORTATION', 'OTHER') THEN
            RAISE_APPLICATION_ERROR(-20305, 'Categoria inv�lida');
        END IF;
        
        -- Validar status
        IF p_status NOT IN ('AVAILABLE', 'RESERVED', 'DONATED', 'EXPIRED') THEN
            RAISE_APPLICATION_ERROR(-20306, 'Status inv�lido');
        END IF;
        
        -- Verificar se doador existe
        SELECT COUNT(*) INTO v_donor_count FROM GS_users WHERE id = p_donor_id;
        IF v_donor_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20307, 'Doador n�o encontrado');
        END IF;
        
        -- Validar data de expira��o se fornecida
        IF p_expiry_date IS NOT NULL AND p_expiry_date <= SYSTIMESTAMP THEN
            RAISE_APPLICATION_ERROR(-20308, 'Data de expira��o deve ser futura');
        END IF;
        
        INSERT INTO GS_donations (
            title, description, location, category, status, 
            quantity, unit, expiry_date, created_at, donor_id
        ) VALUES (
            TRIM(p_title), p_description, TRIM(p_location), p_category, 
            p_status, p_quantity, p_unit, p_expiry_date, 
            SYSTIMESTAMP, p_donor_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Doa��o inserida com sucesso. ID: ' || seq_donations.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir doa��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END INSERT_DONATION;
    
    PROCEDURE UPDATE_DONATION(
        p_id                    GS_donations.id%TYPE,
        p_title                 GS_donations.title%TYPE DEFAULT NULL,
        p_description           GS_donations.description%TYPE DEFAULT NULL,
        p_location              GS_donations.location%TYPE DEFAULT NULL,
        p_category              GS_donations.category%TYPE DEFAULT NULL,
        p_status                GS_donations.status%TYPE DEFAULT NULL,
        p_quantity              GS_donations.quantity%TYPE DEFAULT NULL,
        p_unit                  GS_donations.unit%TYPE DEFAULT NULL,
        p_expiry_date           GS_donations.expiry_date%TYPE DEFAULT NULL
    ) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se doa��o existe
        SELECT COUNT(*) INTO v_count FROM GS_donations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20309, 'Doa��o n�o encontrada');
        END IF;
        
        -- Validar categoria se fornecida
        IF p_category IS NOT NULL AND p_category NOT IN ('FOOD', 'WATER', 'CLOTHING', 'MEDICAL', 'SHELTER', 'EDUCATION', 'TRANSPORTATION', 'OTHER') THEN
            RAISE_APPLICATION_ERROR(-20305, 'Categoria inv�lida');
        END IF;
        
        -- Validar status se fornecido
        IF p_status IS NOT NULL AND p_status NOT IN ('AVAILABLE', 'RESERVED', 'DONATED', 'EXPIRED') THEN
            RAISE_APPLICATION_ERROR(-20306, 'Status inv�lido');
        END IF;
        
        -- Validar quantidade se fornecida
        IF p_quantity IS NOT NULL AND p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20303, 'Quantidade deve ser maior que zero');
        END IF;
        
        -- Validar data de expira��o se fornecida
        IF p_expiry_date IS NOT NULL AND p_expiry_date <= SYSTIMESTAMP THEN
            RAISE_APPLICATION_ERROR(-20308, 'Data de expira��o deve ser futura');
        END IF;
        
        UPDATE GS_donations
        SET 
            title = CASE WHEN p_title IS NOT NULL THEN TRIM(p_title) ELSE title END,
            description = CASE WHEN p_description IS NOT NULL THEN p_description ELSE description END,
            location = CASE WHEN p_location IS NOT NULL THEN TRIM(p_location) ELSE location END,
            category = CASE WHEN p_category IS NOT NULL THEN p_category ELSE category END,
            status = CASE WHEN p_status IS NOT NULL THEN p_status ELSE status END,
            quantity = CASE WHEN p_quantity IS NOT NULL THEN p_quantity ELSE quantity END,
            unit = CASE WHEN p_unit IS NOT NULL THEN p_unit ELSE unit END,
            expiry_date = CASE WHEN p_expiry_date IS NOT NULL THEN p_expiry_date ELSE expiry_date END,
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Doa��o atualizada com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar doa��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END UPDATE_DONATION;
    
    PROCEDURE DELETE_DONATION(p_id GS_donations.id%TYPE) IS
        v_count NUMBER;
        v_matches_count NUMBER;
    BEGIN
        -- Verificar se doa��o existe
        SELECT COUNT(*) INTO v_count FROM GS_donations WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20309, 'Doa��o n�o encontrada');
        END IF;
        
        -- Verificar depend�ncias (matches)
        SELECT COUNT(*) INTO v_matches_count FROM GS_matches WHERE donation_id = p_id;
        IF v_matches_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20310, 'Doa��o possui matches vinculados');
        END IF;
        
        DELETE FROM GS_donations WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Doa��o deletada com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Doa��o n�o encontrada.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar doa��o: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END DELETE_DONATION;
    
    -- ==============================================
    -- MATCHES PROCEDURES IMPLEMENTATION
    -- ==============================================
    
    PROCEDURE INSERT_MATCH(
        p_need_id               GS_matches.need_id%TYPE,
        p_donation_id           GS_matches.donation_id%TYPE,
        p_status                GS_matches.status%TYPE DEFAULT 'PENDING',
        p_matched_quantity      GS_matches.matched_quantity%TYPE DEFAULT NULL,
        p_compatibility_score   GS_matches.compatibility_score%TYPE DEFAULT NULL,
        p_notes                 GS_matches.notes%TYPE DEFAULT NULL
    ) IS
        v_need_count NUMBER;
        v_donation_count NUMBER;
        v_need_quantity NUMBER;
        v_donation_quantity NUMBER;
    BEGIN
        -- Valida��es b�sicas
        IF p_need_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20401, 'ID da necessidade � obrigat�rio');
        END IF;
        
        IF p_donation_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20402, 'ID da doa��o � obrigat�rio');
        END IF;
        
        -- Validar status
        IF p_status NOT IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'REJECTED', 'CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20403, 'Status inv�lido');
        END IF;
        
        -- Verificar se necessidade existe e obter quantidade
        SELECT COUNT(*), MAX(quantity) INTO v_need_count, v_need_quantity 
        FROM GS_needs WHERE id = p_need_id;
        IF v_need_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20404, 'Necessidade n�o encontrada');
        END IF;
        
        -- Verificar se doa��o existe e obter quantidade
        SELECT COUNT(*), MAX(quantity) INTO v_donation_count, v_donation_quantity 
        FROM GS_donations WHERE id = p_donation_id;
        IF v_donation_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20405, 'Doa��o n�o encontrada');
        END IF;
        
        -- Validar quantidade matched se fornecida
        IF p_matched_quantity IS NOT NULL THEN
            IF p_matched_quantity <= 0 THEN
                RAISE_APPLICATION_ERROR(-20406, 'Quantidade matched deve ser maior que zero');
            END IF;
            
            IF p_matched_quantity > v_need_quantity THEN
                RAISE_APPLICATION_ERROR(-20407, 'Quantidade matched n�o pode ser maior que a necessidade');
            END IF;
            
            IF p_matched_quantity > v_donation_quantity THEN
                RAISE_APPLICATION_ERROR(-20408, 'Quantidade matched n�o pode ser maior que a doa��o');
            END IF;
        END IF;
        
        -- Validar score de compatibilidade se fornecido
        IF p_compatibility_score IS NOT NULL THEN
            IF p_compatibility_score < 0 OR p_compatibility_score > 1 THEN
                RAISE_APPLICATION_ERROR(-20409, 'Score de compatibilidade deve estar entre 0 e 1');
            END IF;
        END IF;
        
        -- Verificar se j� existe match entre essa necessidade e doa��o
        SELECT COUNT(*) INTO v_need_count 
        FROM GS_matches 
        WHERE need_id = p_need_id AND donation_id = p_donation_id;
        
        IF v_need_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20410, 'J� existe um match entre essa necessidade e doa��o');
        END IF;
        
        INSERT INTO GS_matches (
            need_id, donation_id, status, matched_quantity, 
            compatibility_score, created_at, notes
        ) VALUES (
            p_need_id, p_donation_id, p_status, p_matched_quantity, 
            p_compatibility_score, SYSTIMESTAMP, p_notes
        );
        
        DBMS_OUTPUT.PUT_LINE('Match inserido com sucesso. ID: ' || seq_matches.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir match: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END INSERT_MATCH;
    
    PROCEDURE UPDATE_MATCH(
        p_id                    GS_matches.id%TYPE,
        p_status                GS_matches.status%TYPE DEFAULT NULL,
        p_matched_quantity      GS_matches.matched_quantity%TYPE DEFAULT NULL,
        p_compatibility_score   GS_matches.compatibility_score%TYPE DEFAULT NULL,
        p_confirmed_at          GS_matches.confirmed_at%TYPE DEFAULT NULL,
        p_notes                 GS_matches.notes%TYPE DEFAULT NULL
    ) IS
        v_count NUMBER;
        v_need_quantity NUMBER;
        v_donation_quantity NUMBER;
        v_need_id NUMBER;
        v_donation_id NUMBER;
    BEGIN
        -- Verificar se match existe e obter dados relacionados
        SELECT COUNT(*), MAX(need_id), MAX(donation_id) 
        INTO v_count, v_need_id, v_donation_id 
        FROM GS_matches WHERE id = p_id;
        
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20411, 'Match n�o encontrado');
        END IF;
        
        -- Validar status se fornecido
        IF p_status IS NOT NULL AND p_status NOT IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'REJECTED', 'CANCELLED') THEN
            RAISE_APPLICATION_ERROR(-20403, 'Status inv�lido');
        END IF;
        
        -- Validar quantidade matched se fornecida
        IF p_matched_quantity IS NOT NULL THEN
            IF p_matched_quantity <= 0 THEN
                RAISE_APPLICATION_ERROR(-20406, 'Quantidade matched deve ser maior que zero');
            END IF;
            
            -- Buscar quantidades da necessidade e doa��o
            SELECT quantity INTO v_need_quantity FROM GS_needs WHERE id = v_need_id;
            SELECT quantity INTO v_donation_quantity FROM GS_donations WHERE id = v_donation_id;
            
            IF p_matched_quantity > v_need_quantity THEN
                RAISE_APPLICATION_ERROR(-20407, 'Quantidade matched n�o pode ser maior que a necessidade');
            END IF;
            
            IF p_matched_quantity > v_donation_quantity THEN
                RAISE_APPLICATION_ERROR(-20408, 'Quantidade matched n�o pode ser maior que a doa��o');
            END IF;
        END IF;
        
        -- Validar score de compatibilidade se fornecido
        IF p_compatibility_score IS NOT NULL THEN
            IF p_compatibility_score < 0 OR p_compatibility_score > 1 THEN
                RAISE_APPLICATION_ERROR(-20409, 'Score de compatibilidade deve estar entre 0 e 1');
            END IF;
        END IF;
        
        UPDATE GS_matches
        SET 
            status = CASE WHEN p_status IS NOT NULL THEN p_status ELSE status END,
            matched_quantity = CASE WHEN p_matched_quantity IS NOT NULL THEN p_matched_quantity ELSE matched_quantity END,
            compatibility_score = CASE WHEN p_compatibility_score IS NOT NULL THEN p_compatibility_score ELSE compatibility_score END,
            confirmed_at = CASE WHEN p_confirmed_at IS NOT NULL THEN p_confirmed_at 
                               WHEN p_status = 'CONFIRMED' THEN SYSTIMESTAMP 
                               ELSE confirmed_at END,
            notes = CASE WHEN p_notes IS NOT NULL THEN p_notes ELSE notes END,
            updated_at = SYSTIMESTAMP
        WHERE id = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Match atualizado com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar match: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END UPDATE_MATCH;
    
    PROCEDURE DELETE_MATCH(p_id GS_matches.id%TYPE) IS
        v_count NUMBER;
    BEGIN
        -- Verificar se match existe
        SELECT COUNT(*) INTO v_count FROM GS_matches WHERE id = p_id;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20411, 'Match n�o encontrado');
        END IF;
        
        DELETE FROM GS_matches WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Match deletado com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Match n�o encontrado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar match: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END DELETE_MATCH;

END GS_MANAGEMENT_PKG;
/
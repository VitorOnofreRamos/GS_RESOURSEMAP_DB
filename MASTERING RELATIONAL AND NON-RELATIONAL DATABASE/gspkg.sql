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
        -- Validações básicas
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome da organização é obrigatório');
        END IF;
        
        IF p_location IS NULL OR TRIM(p_location) = '' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Localização é obrigatória');
        END IF;
        
        INSERT INTO GS_organizations (
            name, description, location, contact_email, 
            contact_phone, type, created_at
        ) VALUES (
            TRIM(p_name), p_description, TRIM(p_location), 
            p_contact_email, p_contact_phone, p_type, SYSTIMESTAMP
        );
        
        DBMS_OUTPUT.PUT_LINE('Organização inserida com sucesso. ID: ' || seq_organizations.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir organização: ' || SQLERRM);
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
            RAISE_APPLICATION_ERROR(-20004, 'Organização não encontrada');
        END IF;
        
        -- Validar tipo se fornecido
        IF p_type IS NOT NULL AND p_type NOT IN ('NGO', 'CHARITY', 'GOVERNMENT', 'RELIGIOUS', 'COMMUNITY') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Tipo de organização inválido');
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
        
        DBMS_OUTPUT.PUT_LINE('Organização atualizada com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar organização: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Update_Organization;
    
    PROCEDURE Delete_Organization(p_id GS_organizations.id%TYPE) IS
        v_count NUMBER;
    BEGIN
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_users WHERE organization_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Organização possui usuários vinculados');
        END IF;
        
        DELETE FROM GS_organizations WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Organização deletada com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Organização não encontrada.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar organização: ' || SQLERRM);
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
        -- Validações básicas
        IF p_email IS NULL OR TRIM(p_email) = '' THEN
            RAISE_APPLICATION_ERROR(-20101, 'Email é obrigatório');
        END IF;
        
        IF p_name IS NULL OR TRIM(p_name) = '' THEN
            RAISE_APPLICATION_ERROR(-20102, 'Nome é obrigatório');
        END IF;
        
        IF p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20103, 'Role inválido');
        END IF;
        
        -- Verificar organização se fornecida
        IF p_organization_id IS NOT NULL THEN
            SELECT COUNT(*) INTO v_org_count FROM GS_organizations WHERE id = p_organization_id;
            IF v_org_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20105, 'Organização não encontrada');
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
        
        DBMS_OUTPUT.PUT_LINE('Usuário inserido com sucesso. ID: ' || seq_users.CURRVAL);
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: Email já existe');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao inserir usuário: ' || SQLERRM);
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
            RAISE_APPLICATION_ERROR(-20106, 'Usuário não encontrado');
        END IF;
        
        -- Validar role se fornecido
        IF p_role IS NOT NULL AND p_role NOT IN ('DONOR', 'NGO_MEMBER', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20103, 'Role inválido');
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
        
        DBMS_OUTPUT.PUT_LINE('Usuário atualizado com sucesso.');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao atualizar usuário: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Update_User;
    
    PROCEDURE Delete_User(p_id GS_users.id%TYPE) IS
        v_count NUMBER;
    BEGIN
        -- Verificar dependências
        SELECT COUNT(*) INTO v_count FROM GS_needs WHERE creator_id = p_id;
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20107, 'Usuário possui necessidades vinculadas');
        END IF;
        
        DELETE FROM GS_users WHERE id = p_id;
        
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Usuário deletado com sucesso.');
            COMMIT;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Usuário não encontrado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao deletar usuário: ' || SQLERRM);
            ROLLBACK;
            RAISE;
    END Delete_User;

END GS_MANAGEMENT_PKG;
/
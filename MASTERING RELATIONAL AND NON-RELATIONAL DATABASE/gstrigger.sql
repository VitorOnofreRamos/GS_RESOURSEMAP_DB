-- TRIGGERS PARA UPDATED_AT
-- Trigger para GS_organizations
CREATE OR REPLACE TRIGGER trg_organizations_updated_at
    BEFORE UPDATE ON GS_organizations
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger para GS_users
CREATE OR REPLACE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON GS_users
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger para GS_needs
CREATE OR REPLACE TRIGGER trg_needs_updated_at
    BEFORE UPDATE ON GS_needs
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger para GS_donations
CREATE OR REPLACE TRIGGER trg_donations_updated_at
    BEFORE UPDATE ON GS_donations
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger para GS_matches
CREATE OR REPLACE TRIGGER trg_matches_updated_at
    BEFORE UPDATE ON GS_matches
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger de audioria
-- Trigger auditoria GS_organizations
CREATE OR REPLACE TRIGGER trg_auditoria_organizations
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_organizations
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
    v_id_registro NUMBER;
BEGIN
    -- Determina o tipo de operação realizada (INSERT, UPDATE ou DELETE)
    IF INSERTING THEN
        v_id_registro := :NEW.id;
        v_operacao := 'INSERT';
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', name: ' || :NEW.name ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', contact_email: ' || :NEW.contact_email ||
                         ', contact_phone: ' || :NEW.contact_phone ||
                         ', type: ' || :NEW.type ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS');
    ELSIF UPDATING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'UPDATE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', name: ' || :OLD.name ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', contact_email: ' || :OLD.contact_email ||
                           ', contact_phone: ' || :OLD.contact_phone ||
                           ', type: ' || :OLD.type ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS');
        
        v_id_registro := :NEW.id;                           
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', name: ' || :NEW.name ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', contact_email: ' || :NEW.contact_email ||
                         ', contact_phone: ' || :NEW.contact_phone ||
                         ', type: ' || :NEW.type ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS');
    ELSIF DELETING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'DELETE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', name: ' || :OLD.name ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', contact_email: ' || :OLD.contact_email ||
                           ', contact_phone: ' || :OLD.contact_phone ||
                           ', type: ' || :OLD.type ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS');
    END IF;
    
    -- Insere o registro na tabela de auditoria
    INSERT INTO GS_auditoria (id, table_name, register_id, operation_type, date_time, db_user, old_data, new_data)
    VALUES (seq_auditoria.NEXTVAL, 'GS_organizations', v_id_registro, v_operacao, SYSTIMESTAMP, USER, v_dados_antigos, v_dados_novos);
END;
/

-- Trigger auditoria GS_users
CREATE OR REPLACE TRIGGER trg_auditoria_users
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_users
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
    v_id_registro NUMBER;
BEGIN
    -- Determina o tipo de operação realizada (INSERT, UPDATE ou DELETE)
    IF INSERTING THEN
        v_id_registro := :NEW.id;
        v_operacao := 'INSERT';
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', email: ' || :NEW.email ||
                         ', phone: ' || :NEW.phone ||
                         ', name: ' || :NEW.name ||
                         ', password: [PROTECTED]' ||
                         ', role: ' || :NEW.role ||
                         ', is_active: ' || :NEW.is_active ||
                         ', last_login: ' || TO_CHAR(:NEW.last_login, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', organization_id: ' || :NEW.organization_id;
    ELSIF UPDATING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'UPDATE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', email: ' || :OLD.email ||
                           ', phone: ' || :OLD.phone ||
                           ', name: ' || :OLD.name ||
                           ', password: [PROTECTED]' ||
                           ', role: ' || :OLD.role ||
                           ', is_active: ' || :OLD.is_active ||
                           ', last_login: ' || TO_CHAR(:OLD.last_login, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', organization_id: ' || :OLD.organization_id;
        
        v_id_registro := :NEW.id;                           
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', email: ' || :NEW.email ||
                         ', phone: ' || :NEW.phone ||
                         ', name: ' || :NEW.name ||
                         ', password: [PROTECTED]' ||
                         ', role: ' || :NEW.role ||
                         ', is_active: ' || :NEW.is_active ||
                         ', last_login: ' || TO_CHAR(:NEW.last_login, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', organization_id: ' || :NEW.organization_id;
    ELSIF DELETING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'DELETE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', email: ' || :OLD.email ||
                           ', phone: ' || :OLD.phone ||
                           ', name: ' || :OLD.name ||
                           ', password: [PROTECTED]' ||
                           ', role: ' || :OLD.role ||
                           ', is_active: ' || :OLD.is_active ||
                           ', last_login: ' || TO_CHAR(:OLD.last_login, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', organization_id: ' || :OLD.organization_id;
    END IF;
    
    -- Insere o registro na tabela de auditoria
    INSERT INTO GS_auditoria (id, table_name, register_id, operation_type, date_time, db_user, old_data, new_data)
    VALUES (seq_auditoria.NEXTVAL, 'GS_users', v_id_registro, v_operacao, SYSTIMESTAMP, USER, v_dados_antigos, v_dados_novos);
END;
/

-- Trigger auditoria GS_needs
CREATE OR REPLACE TRIGGER trg_auditoria_needs
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_needs
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
    v_id_registro NUMBER;
BEGIN
    -- Determina o tipo de operação realizada (INSERT, UPDATE ou DELETE)
    IF INSERTING THEN
        v_id_registro := :NEW.id;
        v_operacao := 'INSERT';
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', title: ' || :NEW.title ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', category: ' || :NEW.category ||
                         ', priority: ' || :NEW.priority ||
                         ', status: ' || :NEW.status ||
                         ', quantity: ' || :NEW.quantity ||
                         ', unit: ' || :NEW.unit ||
                         ', deadline_date: ' || TO_CHAR(:NEW.deadline_date, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', creator_id: ' || :NEW.creator_id ||
                         ', organization_id: ' || :NEW.organization_id;
    ELSIF UPDATING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'UPDATE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', title: ' || :OLD.title ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', category: ' || :OLD.category ||
                           ', priority: ' || :OLD.priority ||
                           ', status: ' || :OLD.status ||
                           ', quantity: ' || :OLD.quantity ||
                           ', unit: ' || :OLD.unit ||
                           ', deadline_date: ' || TO_CHAR(:OLD.deadline_date, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', creator_id: ' || :OLD.creator_id ||
                           ', organization_id: ' || :OLD.organization_id;
        
        v_id_registro := :NEW.id;                           
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', title: ' || :NEW.title ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', category: ' || :NEW.category ||
                         ', priority: ' || :NEW.priority ||
                         ', status: ' || :NEW.status ||
                         ', quantity: ' || :NEW.quantity ||
                         ', unit: ' || :NEW.unit ||
                         ', deadline_date: ' || TO_CHAR(:NEW.deadline_date, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', creator_id: ' || :NEW.creator_id ||
                         ', organization_id: ' || :NEW.organization_id;
    ELSIF DELETING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'DELETE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', title: ' || :OLD.title ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', category: ' || :OLD.category ||
                           ', priority: ' || :OLD.priority ||
                           ', status: ' || :OLD.status ||
                           ', quantity: ' || :OLD.quantity ||
                           ', unit: ' || :OLD.unit ||
                           ', deadline_date: ' || TO_CHAR(:OLD.deadline_date, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', creator_id: ' || :OLD.creator_id ||
                           ', organization_id: ' || :OLD.organization_id;
    END IF;
    
    -- Insere o registro na tabela de auditoria
    INSERT INTO GS_auditoria (id, table_name, register_id, operation_type, date_time, db_user, old_data, new_data)
    VALUES (seq_auditoria.NEXTVAL, 'GS_needs', v_id_registro, v_operacao, SYSTIMESTAMP, USER, v_dados_antigos, v_dados_novos);
END;
/

-- Trigger auditoria GS_donations
CREATE OR REPLACE TRIGGER trg_auditoria_donations
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_donations
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
    v_id_registro NUMBER;
BEGIN
    -- Determina o tipo de operação realizada (INSERT, UPDATE ou DELETE)
    IF INSERTING THEN
        v_id_registro := :NEW.id;
        v_operacao := 'INSERT';
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', title: ' || :NEW.title ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', category: ' || :NEW.category ||
                         ', status: ' || :NEW.status ||
                         ', quantity: ' || :NEW.quantity ||
                         ', unit: ' || :NEW.unit ||
                         ', expiry_date: ' || TO_CHAR(:NEW.expiry_date, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', donor_id: ' || :NEW.donor_id;
    ELSIF UPDATING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'UPDATE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', title: ' || :OLD.title ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', category: ' || :OLD.category ||
                           ', status: ' || :OLD.status ||
                           ', quantity: ' || :OLD.quantity ||
                           ', unit: ' || :OLD.unit ||
                           ', expiry_date: ' || TO_CHAR(:OLD.expiry_date, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', donor_id: ' || :OLD.donor_id;
        
        v_id_registro := :NEW.id;                           
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', title: ' || :NEW.title ||
                         ', description: ' || SUBSTR(:NEW.description, 1, 500) ||
                         ', location: ' || :NEW.location ||
                         ', category: ' || :NEW.category ||
                         ', status: ' || :NEW.status ||
                         ', quantity: ' || :NEW.quantity ||
                         ', unit: ' || :NEW.unit ||
                         ', expiry_date: ' || TO_CHAR(:NEW.expiry_date, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', donor_id: ' || :NEW.donor_id;
    ELSIF DELETING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'DELETE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', title: ' || :OLD.title ||
                           ', description: ' || SUBSTR(:OLD.description, 1, 500) ||
                           ', location: ' || :OLD.location ||
                           ', category: ' || :OLD.category ||
                           ', status: ' || :OLD.status ||
                           ', quantity: ' || :OLD.quantity ||
                           ', unit: ' || :OLD.unit ||
                           ', expiry_date: ' || TO_CHAR(:OLD.expiry_date, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', donor_id: ' || :OLD.donor_id;
    END IF;
    
    -- Insere o registro na tabela de auditoria
    INSERT INTO GS_auditoria (id, table_name, register_id, operation_type, date_time, db_user, old_data, new_data)
    VALUES (seq_auditoria.NEXTVAL, 'GS_donations', v_id_registro, v_operacao, SYSTIMESTAMP, USER, v_dados_antigos, v_dados_novos);
END;
/

-- Trigger auditoria GS_matches
CREATE OR REPLACE TRIGGER trg_auditoria_matches
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_matches
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
    v_id_registro NUMBER;
BEGIN
    -- Determina o tipo de operação realizada (INSERT, UPDATE ou DELETE)
    IF INSERTING THEN
        v_id_registro := :NEW.id;
        v_operacao := 'INSERT';
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', need_id: ' || :NEW.need_id ||
                         ', donation_id: ' || :NEW.donation_id ||
                         ', status: ' || :NEW.status ||
                         ', matched_quantity: ' || :NEW.matched_quantity ||
                         ', compatibility_score: ' || :NEW.compatibility_score ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', confirmed_at: ' || TO_CHAR(:NEW.confirmed_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', notes: ' || SUBSTR(:NEW.notes, 1, 500);
    ELSIF UPDATING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'UPDATE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', need_id: ' || :OLD.need_id ||
                           ', donation_id: ' || :OLD.donation_id ||
                           ', status: ' || :OLD.status ||
                           ', matched_quantity: ' || :OLD.matched_quantity ||
                           ', compatibility_score: ' || :OLD.compatibility_score ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', confirmed_at: ' || TO_CHAR(:OLD.confirmed_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', notes: ' || SUBSTR(:OLD.notes, 1, 500);
        
        v_id_registro := :NEW.id;                           
        v_dados_novos := 'id: ' || :NEW.id || 
                         ', need_id: ' || :NEW.need_id ||
                         ', donation_id: ' || :NEW.donation_id ||
                         ', status: ' || :NEW.status ||
                         ', matched_quantity: ' || :NEW.matched_quantity ||
                         ', compatibility_score: ' || :NEW.compatibility_score ||
                         ', created_at: ' || TO_CHAR(:NEW.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', updated_at: ' || TO_CHAR(:NEW.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', confirmed_at: ' || TO_CHAR(:NEW.confirmed_at, 'YYYY-MM-DD HH24:MI:SS') ||
                         ', notes: ' || SUBSTR(:NEW.notes, 1, 500);
    ELSIF DELETING THEN
        v_id_registro := :OLD.id;
        v_operacao := 'DELETE';
        v_dados_antigos := 'id: ' || :OLD.id || 
                           ', need_id: ' || :OLD.need_id ||
                           ', donation_id: ' || :OLD.donation_id ||
                           ', status: ' || :OLD.status ||
                           ', matched_quantity: ' || :OLD.matched_quantity ||
                           ', compatibility_score: ' || :OLD.compatibility_score ||
                           ', created_at: ' || TO_CHAR(:OLD.created_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', updated_at: ' || TO_CHAR(:OLD.updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', confirmed_at: ' || TO_CHAR(:OLD.confirmed_at, 'YYYY-MM-DD HH24:MI:SS') ||
                           ', notes: ' || SUBSTR(:OLD.notes, 1, 500);
    END IF;
    
    -- Insere o registro na tabela de auditoria
    INSERT INTO GS_auditoria (id, table_name, register_id, operation_type, date_time, db_user, old_data, new_data)
    VALUES (seq_auditoria.NEXTVAL, 'GS_matches', v_id_registro, v_operacao, SYSTIMESTAMP, USER, v_dados_antigos, v_dados_novos);
END;
/

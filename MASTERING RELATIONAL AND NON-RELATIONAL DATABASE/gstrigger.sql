-- Trigger auditoria needs
CREATE OR REPLACE TRIGGER trg_auditoria_needs
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_needs
    FOR EACH ROW
DECLARE
BEGIN
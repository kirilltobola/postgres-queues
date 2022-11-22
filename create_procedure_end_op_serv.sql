CREATE OR REPLACE PROCEDURE end_operator_service(operator_id_in integer)
LANGUAGE 'plpgsql'
AS $body$
DECLARE
    var_queue_id integer;
BEGIN
    SELECT Q.queue_id
    INTO var_queue_id
    FROM queue AS Q
    WHERE Q.operator_id = operator_id_in
    AND Q.start_service_date IS NOT NULL
    AND Q.end_service_date IS NULL;

    IF NOT FOUND THEN
        RAISE 'NOT FOUND';
    END IF;

    UPDATE queue q
    SET end_service_date = CURRENT_TIMESTAMP
    WHERE queue_id = var_queue_id;
END;
$body$;

CREATE OR REPLACE PROCEDURE end_operator_working(operator_id_in integer)
LANGUAGE 'plpgsql'
AS $body$
DECLARE
    var_customer_full_name character varying;
    var_queue_number integer;
BEGIN
    PERFORM operator_id
    FROM operators
    WHERE operator_id = operator_id_in
    AND is_working = true;
    IF NOT FOUND THEN
        RETURN;
    END IF;

    SELECT customer_full_name, queue_number
    INTO var_customer_full_name, var_queue_number
    FROM queue
    WHERE start_service_date IS NOT NULL
    AND end_service_date IS NULL
    AND operator_id = operator_id_in;
    IF FOUND THEN
        RAISE 'CustomerFullName = %, QueueNumber = %, still processing',
        var_customer_full_name,
        var_queue_number; 
    END IF;

    -- LOCK TABLE operators IN SHARE MODE;

    UPDATE operators
    SET is_working = false
    WHERE operator_id = operator_id_in;
END;
$body$;

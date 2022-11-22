CREATE OR REPLACE FUNCTION start_operator_service(operator_id_in integer)
RETURNS TABLE( 
    r_customer_full_name character varying,
    r_queue_number integer,
    r_operator_place character varying
)
LANGUAGE 'plpgsql'
AS $body$
DECLARE 
    var_customer_full_name character varying;
    var_queue_number integer;
    var_queue_id integer;
BEGIN
    UPDATE operators
    SET is_working = true
    WHERE operator_id = operator_id_in;

    SELECT Q.customer_full_name, Q.queue_number
    INTO var_customer_full_name, var_queue_number
    FROM queue Q
    WHERE Q.start_service_date IS NOT NULL 
    AND Q.end_service_date IS NULL
    AND Q.operator_id = operator_id_in;
    IF FOUND THEN
        RAISE 'CustomerFullName = %, QueueNumber = %, still processing',
        var_customer_full_name,
        var_queue_number;
    END IF;

    SELECT queue_id, customer_full_name, queue_number
    INTO var_queue_id, r_customer_full_name, r_queue_number
    FROM queue
    WHERE DATE(registration_date) = CURRENT_DATE
    AND start_service_date IS NULL
    AND operator_id = operator_id_in
    ORDER BY queue_number
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN;
    END IF;

    UPDATE queue
    SET start_service_date = CURRENT_TIMESTAMP
    WHERE queue_id = var_queue_id;

    SELECT operator_place
    INTO r_operator_place
    FROM operators
    WHERE operator_id = operator_id_in;

    RETURN NEXT;
END;
$body$;

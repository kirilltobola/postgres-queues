CREATE OR REPLACE FUNCTION create_record_queue(customer_full_name_in character varying)
RETURNS TABLE(
    customer_full_name character varying,
    queue_number integer,
    operator_place character varying
)
LANGUAGE 'plpgsql'
AS $body$
DECLARE 
    next_operator_id integer;
BEGIN
    -- под вопросом
    LOCK TABLE operators IN ROW EXCLUSIVE MODE;

    PERFORM *
    FROM operators as O
    WHERE O.is_working = true;
    IF NOT FOUND THEN
        RAISE 'Not found';
    END IF;

    LOCK TABLE queue IN EXCLUSIVE MODE;

    SELECT 
        O.operator_id,
        COALESCE(MAX(Q.queue_number), 0) cnt_clients_in_queue,
        O.operator_place
    INTO next_operator_id, queue_number, operator_place
    FROM operators as O
    LEFT JOIN queue as Q
    ON O.operator_id = Q.operator_id
    WHERE O.is_working = TRUE
    AND (DATE(Q.registration_date) = CURRENT_DATE OR Q.registration_date IS NULL)
    GROUP BY O.operator_id
    ORDER BY cnt_clients_in_queue
    LIMIT 1;

    customer_full_name := customer_full_name_in;
    queue_number := queue_number + 1;

    INSERT INTO queue(operator_id, customer_full_name, queue_number) 
    VALUES (next_operator_id, customer_full_name, queue_number);

    RETURN NEXT;
END;
$body$;

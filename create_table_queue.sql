CREATE TABLE public.queue
(
    queue_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    operator_id integer NOT NULL,
    registration_date timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_full_name character varying(100) NOT NULL,
    queue_number integer NOT NULL,
    start_service_date timestamp without time zone,
    end_service_date timestamp without time zone,
    PRIMARY KEY (queue_id),
    CONSTRAINT operator_id_fk FOREIGN KEY (operator_id)
        REFERENCES public.operators (operator_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.queue
    OWNER to postgres;

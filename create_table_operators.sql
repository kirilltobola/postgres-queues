CREATE TABLE public.operators
(
    operator_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
    operator_place character varying(100) NOT NULL,
    is_working boolean NOT NULL DEFAULT FALSE,
    PRIMARY KEY (operator_id)
);

ALTER TABLE IF EXISTS public.operators
    OWNER to postgres;

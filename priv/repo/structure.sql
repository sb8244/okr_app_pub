--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE analytics_events (
    id bigint NOT NULL,
    type character varying(255) NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    user_id character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: analytics_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analytics_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analytics_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analytics_events_id_seq OWNED BY analytics_events.id;


--
-- Name: cycles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cycles (
    id bigint NOT NULL,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id character varying(255) NOT NULL,
    title text NOT NULL
);


--
-- Name: cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cycles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cycles_id_seq OWNED BY cycles.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id bigint NOT NULL,
    name text NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug text NOT NULL,
    pinned boolean DEFAULT false NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups_users (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groups_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_users_id_seq OWNED BY groups_users.id;


--
-- Name: key_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE key_results (
    id bigint NOT NULL,
    content text NOT NULL,
    cancelled_at timestamp without time zone,
    mid_score numeric DEFAULT 0 NOT NULL,
    final_score numeric DEFAULT 0 NOT NULL,
    objective_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: key_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE key_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE key_results_id_seq OWNED BY key_results.id;


--
-- Name: objective_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE objective_assessments (
    id bigint NOT NULL,
    assessment text NOT NULL,
    objective_id bigint NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: objective_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE objective_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: objective_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE objective_assessments_id_seq OWNED BY objective_assessments.id;


--
-- Name: objective_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE objective_links (
    id bigint NOT NULL,
    deleted_at timestamp without time zone,
    source_objective_id bigint NOT NULL,
    linked_to_objective_id bigint NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: objective_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE objective_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: objective_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE objective_links_id_seq OWNED BY objective_links.id;


--
-- Name: objectives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE objectives (
    id bigint NOT NULL,
    content text NOT NULL,
    cancelled_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    okr_id bigint NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: objectives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE objectives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: objectives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE objectives_id_seq OWNED BY objectives.id;


--
-- Name: okr_reflections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE okr_reflections (
    id bigint NOT NULL,
    reflection text NOT NULL,
    okr_id bigint NOT NULL,
    deleted_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: okr_reflections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE okr_reflections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: okr_reflections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE okr_reflections_id_seq OWNED BY okr_reflections.id;


--
-- Name: okrs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE okrs (
    id bigint NOT NULL,
    cycle_id bigint NOT NULL,
    user_id character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id bigint
);


--
-- Name: okrs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE okrs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: okrs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE okrs_id_seq OWNED BY okrs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id character varying(255) NOT NULL,
    user_name text NOT NULL,
    active boolean NOT NULL,
    family_name text,
    given_name text,
    middle_name text,
    emails jsonb[] DEFAULT ARRAY[]::jsonb[],
    roles text[] DEFAULT ARRAY[]::text[],
    manager_id text,
    manager_display_name text,
    department text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: analytics_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analytics_events ALTER COLUMN id SET DEFAULT nextval('analytics_events_id_seq'::regclass);


--
-- Name: cycles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cycles ALTER COLUMN id SET DEFAULT nextval('cycles_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: groups_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users ALTER COLUMN id SET DEFAULT nextval('groups_users_id_seq'::regclass);


--
-- Name: key_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_results ALTER COLUMN id SET DEFAULT nextval('key_results_id_seq'::regclass);


--
-- Name: objective_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_assessments ALTER COLUMN id SET DEFAULT nextval('objective_assessments_id_seq'::regclass);


--
-- Name: objective_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_links ALTER COLUMN id SET DEFAULT nextval('objective_links_id_seq'::regclass);


--
-- Name: objectives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY objectives ALTER COLUMN id SET DEFAULT nextval('objectives_id_seq'::regclass);


--
-- Name: okr_reflections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY okr_reflections ALTER COLUMN id SET DEFAULT nextval('okr_reflections_id_seq'::regclass);


--
-- Name: okrs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY okrs ALTER COLUMN id SET DEFAULT nextval('okrs_id_seq'::regclass);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: cycles cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cycles
    ADD CONSTRAINT cycles_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups_users groups_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_pkey PRIMARY KEY (id);


--
-- Name: key_results key_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_results
    ADD CONSTRAINT key_results_pkey PRIMARY KEY (id);


--
-- Name: objective_assessments objective_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_assessments
    ADD CONSTRAINT objective_assessments_pkey PRIMARY KEY (id);


--
-- Name: objective_links objective_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_links
    ADD CONSTRAINT objective_links_pkey PRIMARY KEY (id);


--
-- Name: objectives objectives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objectives
    ADD CONSTRAINT objectives_pkey PRIMARY KEY (id);


--
-- Name: okr_reflections okr_reflections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okr_reflections
    ADD CONSTRAINT okr_reflections_pkey PRIMARY KEY (id);


--
-- Name: okrs okrs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okrs
    ADD CONSTRAINT okrs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: analytics_events_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_type_index ON analytics_events USING btree (type);


--
-- Name: analytics_events_type_inserted_at__metadata__owner_id__text_ind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_type_inserted_at__metadata__owner_id__text_ind ON analytics_events USING btree (type, inserted_at, ((metadata ->> 'owner_id'::text)));


--
-- Name: analytics_events_type_inserted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX analytics_events_type_inserted_at_index ON analytics_events USING btree (type, inserted_at);


--
-- Name: groups_users_group_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX groups_users_group_id_user_id_index ON groups_users USING btree (group_id, user_id);


--
-- Name: key_results_objective_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX key_results_objective_id_index ON key_results USING btree (objective_id);


--
-- Name: objective_assessments_objective_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX objective_assessments_objective_id_index ON objective_assessments USING btree (objective_id);


--
-- Name: objective_assessments_unique_per_objective_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX objective_assessments_unique_per_objective_id ON objective_assessments USING btree (objective_id) WHERE (deleted_at IS NULL);


--
-- Name: objective_links_linked_to_objective_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX objective_links_linked_to_objective_id_index ON objective_links USING btree (linked_to_objective_id);


--
-- Name: objective_links_source_objective_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX objective_links_source_objective_id_index ON objective_links USING btree (source_objective_id);


--
-- Name: objective_links_source_objective_id_linked_to_objective_id_inde; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX objective_links_source_objective_id_linked_to_objective_id_inde ON objective_links USING btree (source_objective_id, linked_to_objective_id) WHERE (deleted_at IS NULL);


--
-- Name: objectives_deleted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX objectives_deleted_at_index ON objectives USING btree (deleted_at);


--
-- Name: objectives_okr_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX objectives_okr_id_index ON objectives USING btree (okr_id);


--
-- Name: okr_reflections_unique_per_okr_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX okr_reflections_unique_per_okr_id ON okr_reflections USING btree (okr_id) WHERE (deleted_at IS NULL);


--
-- Name: okrs_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX okrs_user_id_index ON okrs USING btree (user_id);


--
-- Name: users_active_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_active_index ON users USING btree (active);


--
-- Name: users_active_user_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_active_user_name_index ON users USING btree (active, user_name);


--
-- Name: analytics_events analytics_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY analytics_events
    ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: cycles cycles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cycles
    ADD CONSTRAINT cycles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: groups_users groups_users_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: groups_users groups_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: key_results key_results_objective_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY key_results
    ADD CONSTRAINT key_results_objective_id_fkey FOREIGN KEY (objective_id) REFERENCES objectives(id);


--
-- Name: objective_assessments objective_assessments_objective_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_assessments
    ADD CONSTRAINT objective_assessments_objective_id_fkey FOREIGN KEY (objective_id) REFERENCES objectives(id);


--
-- Name: objective_links objective_links_linked_to_objective_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_links
    ADD CONSTRAINT objective_links_linked_to_objective_id_fkey FOREIGN KEY (linked_to_objective_id) REFERENCES objectives(id);


--
-- Name: objective_links objective_links_source_objective_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objective_links
    ADD CONSTRAINT objective_links_source_objective_id_fkey FOREIGN KEY (source_objective_id) REFERENCES objectives(id);


--
-- Name: objectives objectives_okr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY objectives
    ADD CONSTRAINT objectives_okr_id_fkey FOREIGN KEY (okr_id) REFERENCES okrs(id);


--
-- Name: okr_reflections okr_reflections_okr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okr_reflections
    ADD CONSTRAINT okr_reflections_okr_id_fkey FOREIGN KEY (okr_id) REFERENCES okrs(id);


--
-- Name: okrs okrs_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okrs
    ADD CONSTRAINT okrs_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES cycles(id);


--
-- Name: okrs okrs_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okrs
    ADD CONSTRAINT okrs_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: okrs okrs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY okrs
    ADD CONSTRAINT okrs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20180812183008), (20180814030903), (20180814030908), (20180814031925), (20180814034953), (20180816012607), (20180816012846), (20180816013251), (20180816014128), (20180816015149), (20180816021954), (20180816024011), (20180816030333), (20180816030403), (20180816031145), (20180817041000), (20180827024648), (20180906192907), (20180909042940), (20180913052032), (20180914034216), (20180914035604), (20181008164313), (20181029040415), (20181029152935), (20181029211851), (20181029214411);


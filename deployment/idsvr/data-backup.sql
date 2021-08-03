--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2 (Debian 13.2-1.pgdg100+1)
-- Dumped by pg_dump version 13.2 (Debian 13.2-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    account_id character varying(64) DEFAULT public.uuid_generate_v1() NOT NULL,
    username character varying(64) NOT NULL,
    password character varying(128),
    email character varying(64),
    phone character varying(32),
    attributes jsonb,
    active smallint DEFAULT 0 NOT NULL,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: COLUMN accounts.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.account_id IS 'Account id, or username, of this account. Unique.';


--
-- Name: COLUMN accounts.password; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.password IS 'The hashed password. Optional';


--
-- Name: COLUMN accounts.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.email IS 'The associated email address. Optional';


--
-- Name: COLUMN accounts.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.phone IS 'The phone number of the account owner. Optional';


--
-- Name: COLUMN accounts.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.attributes IS 'Key/value map of additional attributes associated with the account.';


--
-- Name: COLUMN accounts.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.active IS 'Indicates if this account has been activated or not. Activation is usually via email or sms.';


--
-- Name: COLUMN accounts.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.created IS 'Time since epoch of account creation, in seconds';


--
-- Name: COLUMN accounts.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.accounts.updated IS 'Time since epoch of latest account update, in seconds';


--
-- Name: audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit (
    id character varying(64) NOT NULL,
    instant timestamp without time zone NOT NULL,
    event_instant character varying(64) NOT NULL,
    server character varying(255) NOT NULL,
    message text NOT NULL,
    event_type character varying(48) NOT NULL,
    subject character varying(128),
    client character varying(128),
    resource character varying(128),
    authenticated_subject character varying(128),
    authenticated_client character varying(128),
    acr character varying(128),
    endpoint character varying(255),
    session character varying(128)
);


ALTER TABLE public.audit OWNER TO postgres;

--
-- Name: COLUMN audit.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.id IS 'Unique ID of the log message';


--
-- Name: COLUMN audit.instant; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.instant IS 'Moment that the event was logged';


--
-- Name: COLUMN audit.event_instant; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.event_instant IS 'Moment that the event occurred';


--
-- Name: COLUMN audit.server; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.server IS 'The server node where the event occurred';


--
-- Name: COLUMN audit.message; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.message IS 'Message describing the event';


--
-- Name: COLUMN audit.event_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.event_type IS 'Type of event that the message is about';


--
-- Name: COLUMN audit.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.subject IS 'The subject (i.e., user) effected by the event';


--
-- Name: COLUMN audit.client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.client IS 'The client ID effected by the event';


--
-- Name: COLUMN audit.resource; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.resource IS 'The resource ID effected by the event';


--
-- Name: COLUMN audit.authenticated_subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.authenticated_subject IS 'The authenticated subject (i.e., user) effected by the event';


--
-- Name: COLUMN audit.authenticated_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.authenticated_client IS 'The authenticated client effected by the event';


--
-- Name: COLUMN audit.acr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.acr IS 'The ACR used to authenticate the subject (i.e., user)';


--
-- Name: COLUMN audit.endpoint; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.endpoint IS 'The endpoint where the event was triggered';


--
-- Name: COLUMN audit.session; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.audit.session IS 'The session ID in which the event was triggered';


--
-- Name: buckets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.buckets (
    subject character varying(128) NOT NULL,
    purpose character varying(64) NOT NULL,
    attributes jsonb NOT NULL,
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL
);


ALTER TABLE public.buckets OWNER TO postgres;

--
-- Name: COLUMN buckets.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.subject IS 'The subject that together with the purpose identify this bucket';


--
-- Name: COLUMN buckets.purpose; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.purpose IS 'The purpose of this bucket, eg. "login_attempt_counter"';


--
-- Name: COLUMN buckets.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.attributes IS 'All attributes stored for this subject/purpose';


--
-- Name: COLUMN buckets.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.created IS 'When this bucket was created';


--
-- Name: COLUMN buckets.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.buckets.updated IS 'When this bucket was last updated';


--
-- Name: delegations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delegations (
    id character varying(40) NOT NULL,
    owner character varying(128) NOT NULL,
    created bigint NOT NULL,
    expires bigint NOT NULL,
    scope character varying(1000),
    scope_claims text,
    client_id character varying(128) NOT NULL,
    redirect_uri character varying(512),
    status character varying(16) NOT NULL,
    claims text,
    authentication_attributes text,
    authorization_code_hash character varying(89)
);


ALTER TABLE public.delegations OWNER TO postgres;

--
-- Name: COLUMN delegations.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.id IS 'Unique identifier';


--
-- Name: COLUMN delegations.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.owner IS 'Moment when delegations record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN delegations.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.expires IS 'Moment when delegation expires, as measured in number of seconds since epoch';


--
-- Name: COLUMN delegations.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.scope IS 'Space delimited list of scope values';


--
-- Name: COLUMN delegations.scope_claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.scope_claims IS 'JSON with the scope-claims configuration at the time of delegation issuance';


--
-- Name: COLUMN delegations.client_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.client_id IS 'Reference to a client; non-enforced';


--
-- Name: COLUMN delegations.redirect_uri; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.redirect_uri IS 'Optional value for the redirect_uri parameter, when provided in a request for delegation';


--
-- Name: COLUMN delegations.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.status IS 'Status of the delegation instance, from {''issued'', ''revoked''}';


--
-- Name: COLUMN delegations.claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.claims IS 'Optional JSON that contains a list of claims that are part of the delegation';


--
-- Name: COLUMN delegations.authentication_attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.authentication_attributes IS 'The JSON-serialized AuthenticationAttributes established for this delegation';


--
-- Name: COLUMN delegations.authorization_code_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.delegations.authorization_code_hash IS 'A hash of the authorization code that was provided when this delegation was issued.';


--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id character varying(64) NOT NULL,
    device_id character varying(64),
    account_id character varying(256),
    external_id character varying(32),
    alias character varying(30),
    form_factor character varying(10),
    device_type character varying(50),
    owner character varying(256),
    attributes jsonb,
    expires bigint,
    created bigint NOT NULL,
    updated bigint NOT NULL
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: COLUMN devices.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.id IS 'Unique ID of the device';


--
-- Name: COLUMN devices.device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.device_id IS 'The device ID that identifies the physical device';


--
-- Name: COLUMN devices.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.account_id IS 'The user account ID that is associated with the device';


--
-- Name: COLUMN devices.external_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.external_id IS 'The phone or other identifying number of the device (if it has one)';


--
-- Name: COLUMN devices.alias; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.alias IS 'The user-recognizable name or mnemonic identifier of the device (e.g., my work iPhone)';


--
-- Name: COLUMN devices.form_factor; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.form_factor IS 'The type or form of device (e.g., laptop, phone, tablet, etc.)';


--
-- Name: COLUMN devices.device_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.device_type IS 'The device type (i.e., make, manufacturer, provider, class)';


--
-- Name: COLUMN devices.owner; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.owner IS 'The owner of the device. This is the user who has administrative rights on the device';


--
-- Name: COLUMN devices.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.attributes IS 'Key/value map of custom attributes associated with the device.';


--
-- Name: COLUMN devices.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.expires IS 'Time since epoch of device expiration, in seconds';


--
-- Name: COLUMN devices.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.created IS 'Time since epoch of device creation, in seconds';


--
-- Name: COLUMN devices.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.devices.updated IS 'Time since epoch of latest device update, in seconds';


--
-- Name: dynamically_registered_clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dynamically_registered_clients (
    client_id character varying(64) NOT NULL,
    client_secret character varying(128),
    instance_of_client character varying(64),
    created timestamp without time zone NOT NULL,
    updated timestamp without time zone NOT NULL,
    initial_client character varying(64),
    authenticated_user character varying(64),
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    status character varying(12) DEFAULT 'active'::character varying NOT NULL,
    scope text,
    redirect_uris text,
    grant_types character varying(128)
);


ALTER TABLE public.dynamically_registered_clients OWNER TO postgres;

--
-- Name: COLUMN dynamically_registered_clients.client_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.client_id IS 'The client ID of this client instance';


--
-- Name: COLUMN dynamically_registered_clients.client_secret; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.client_secret IS 'The hash of this client''s secret';


--
-- Name: COLUMN dynamically_registered_clients.instance_of_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.instance_of_client IS 'The client ID on which this instance is based, or NULL if this is a non-templatized client';


--
-- Name: COLUMN dynamically_registered_clients.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.created IS 'When this client was originally created (in UTC time)';


--
-- Name: COLUMN dynamically_registered_clients.updated; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.updated IS 'When this client was last updated (in UTC time)';


--
-- Name: COLUMN dynamically_registered_clients.initial_client; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.initial_client IS 'In case the user authenticated, this value contains a client_id value of the initial token. If the initial token was issued through a client credentials-flow, the initial_client value is set to the client that authenticated. Registration without initial token (i.e. with no authentication) will result in a null value for initial_client';


--
-- Name: COLUMN dynamically_registered_clients.authenticated_user; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.authenticated_user IS 'In case a user authenticated (through a client), this value contains the sub value of the initial token';


--
-- Name: COLUMN dynamically_registered_clients.attributes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.attributes IS 'Arbitrary attributes tied to this client';


--
-- Name: COLUMN dynamically_registered_clients.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.status IS 'The current status of the client, allowed values are "active", "inactive" and "revoked"';


--
-- Name: COLUMN dynamically_registered_clients.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.scope IS 'Space separated list of scopes defined for this client (non-templatized clients only)';


--
-- Name: COLUMN dynamically_registered_clients.redirect_uris; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.redirect_uris IS 'Space separated list of redirect URI''s defined for this client (non-templatized clients only)';


--
-- Name: COLUMN dynamically_registered_clients.grant_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.dynamically_registered_clients.grant_types IS 'Space separated list of grant types defined for this client (non-templatized clients only)';


--
-- Name: linked_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.linked_accounts (
    account_id character varying(64),
    linked_account_id character varying(64) NOT NULL,
    linked_account_domain_name character varying(64) NOT NULL,
    linking_account_manager character varying(128),
    created timestamp without time zone NOT NULL
);


ALTER TABLE public.linked_accounts OWNER TO postgres;

--
-- Name: COLUMN linked_accounts.account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.account_id IS 'Account ID, typically a global one, of the account being linked from (the linker)';


--
-- Name: COLUMN linked_accounts.linked_account_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.linked_account_id IS 'Account ID, typically a local or legacy one, of the account being linked (the linkee)';


--
-- Name: COLUMN linked_accounts.linked_account_domain_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.linked_accounts.linked_account_domain_name IS 'The domain (i.e., organizational group or realm) of the account being linked';


--
-- Name: nonces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nonces (
    token character varying(64) NOT NULL,
    reference_data text NOT NULL,
    created bigint NOT NULL,
    ttl bigint NOT NULL,
    consumed bigint,
    status character varying(16) DEFAULT 'issued'::character varying NOT NULL
);


ALTER TABLE public.nonces OWNER TO postgres;

--
-- Name: COLUMN nonces.token; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.token IS 'Value issued as random nonce';


--
-- Name: COLUMN nonces.reference_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.reference_data IS 'Value that is referenced by the nonce value';


--
-- Name: COLUMN nonces.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.created IS 'Moment when nonce record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN nonces.ttl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.ttl IS 'Time To Live, period in seconds since created after which the nonce expires';


--
-- Name: COLUMN nonces.consumed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.consumed IS 'Moment when nonce was consumed, as measured in number of seconds since epoch';


--
-- Name: COLUMN nonces.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.nonces.status IS 'Status of the nonce from {''issued'', ''revoked'', ''used''}';


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(64) NOT NULL,
    session_data text NOT NULL,
    expires bigint NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: COLUMN sessions.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.id IS 'id given to the session';


--
-- Name: COLUMN sessions.session_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.session_data IS 'Value that is referenced by the session id';


--
-- Name: COLUMN sessions.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.sessions.expires IS 'Moment when session record expires, as measured in number of seconds since epoch';


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    token_hash character varying(89) NOT NULL,
    id character varying(64),
    delegations_id character varying(40) NOT NULL,
    purpose character varying(32) NOT NULL,
    usage character varying(8) NOT NULL,
    format character varying(32) NOT NULL,
    created bigint NOT NULL,
    expires bigint NOT NULL,
    scope character varying(1000),
    scope_claims text,
    status character varying(16) NOT NULL,
    issuer character varying(200) NOT NULL,
    subject character varying(64) NOT NULL,
    audience character varying(512),
    not_before bigint,
    claims text,
    meta_data text
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: COLUMN tokens.token_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.token_hash IS 'Base64 encoded sha-512 hash of the token value.';


--
-- Name: COLUMN tokens.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.id IS 'Identifier of the token, when it exists; this can be the value from the ''jti''-claim of a JWT, etc. Opaque tokens do not have an id.';


--
-- Name: COLUMN tokens.delegations_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.delegations_id IS 'Reference to the delegation instance that underlies the token';


--
-- Name: COLUMN tokens.purpose; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.purpose IS 'Purpose of the token, i.e. ''nonce'', ''accesstoken'', ''refreshtoken'', ''custom'', etc.';


--
-- Name: COLUMN tokens.usage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.usage IS 'Indication whether the token is a bearer or proof token, from {"bearer", "proof"}';


--
-- Name: COLUMN tokens.format; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.format IS 'The format of the token, i.e. ''opaque'', ''jwt'', etc.';


--
-- Name: COLUMN tokens.created; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.created IS 'Moment when token record is created, as measured in number of seconds since epoch';


--
-- Name: COLUMN tokens.expires; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.expires IS 'Moment when token expires, as measured in number of seconds since epoch';


--
-- Name: COLUMN tokens.scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.scope IS 'Space delimited list of scope values';


--
-- Name: COLUMN tokens.scope_claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.scope_claims IS 'Space delimited list of scope-claims values';


--
-- Name: COLUMN tokens.status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.status IS 'Status of the token from {''issued'', ''used'', ''revoked''}';


--
-- Name: COLUMN tokens.issuer; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.issuer IS 'Optional name of the issuer of the token (jwt.iss)';


--
-- Name: COLUMN tokens.subject; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.subject IS 'Optional subject of the token (jwt.sub)';


--
-- Name: COLUMN tokens.audience; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.audience IS 'Space separated list of audiences for the token (jwt.aud)';


--
-- Name: COLUMN tokens.not_before; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.not_before IS 'Moment before which the token is not valid, as measured in number of seconds since epoch (jwt.nbf)';


--
-- Name: COLUMN tokens.claims; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tokens.claims IS 'Optional JSON-blob that contains a list of claims that are part of the token';


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (account_id, username, password, email, phone, attributes, active, created, updated) FROM stdin;
c02d2dde-ee25-11eb-9535-0242ac130005	demouser	$5$rounds=20000$zXoLTfTLXOUevIIf$xKoU.9qf6qj24vmCp3Jm/R915tcOTzUdp7jRqd9YP69	demo@user.com	\N	{"name": {"givenName": "Demo", "familyName": "User"}, "emails": [{"value": "demo@user.com", "primary": true}], "agreeToTerms": "on", "urn:se:curity:scim:2.0:Devices": []}	1	1627313147	1627313147
\.


--
-- Data for Name: audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit (id, instant, event_instant, server, message, event_type, subject, client, resource, authenticated_subject, authenticated_client, acr, endpoint, session) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.buckets (subject, purpose, attributes, created, updated) FROM stdin;
\.


--
-- Data for Name: delegations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delegations (id, owner, created, expires, scope, scope_claims, client_id, redirect_uri, status, claims, authentication_attributes, authorization_code_hash) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, device_id, account_id, external_id, alias, form_factor, device_type, owner, attributes, expires, created, updated) FROM stdin;
\.


--
-- Data for Name: dynamically_registered_clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dynamically_registered_clients (client_id, client_secret, instance_of_client, created, updated, initial_client, authenticated_user, attributes, status, scope, redirect_uris, grant_types) FROM stdin;
\.


--
-- Data for Name: linked_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.linked_accounts (account_id, linked_account_id, linked_account_domain_name, linking_account_manager, created) FROM stdin;
\.


--
-- Data for Name: nonces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nonces (token, reference_data, created, ttl, consumed, status) FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, session_data, expires) FROM stdin;
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (token_hash, id, delegations_id, purpose, usage, format, created, expires, scope, scope_claims, status, issuer, subject, audience, not_before, claims, meta_data) FROM stdin;
\.


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (subject, purpose);


--
-- Name: delegations delegations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delegations
    ADD CONSTRAINT delegations_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: dynamically_registered_clients dynamically_registered_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dynamically_registered_clients
    ADD CONSTRAINT dynamically_registered_clients_pkey PRIMARY KEY (client_id);


--
-- Name: linked_accounts linked_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.linked_accounts
    ADD CONSTRAINT linked_accounts_pkey PRIMARY KEY (linked_account_id, linked_account_domain_name);


--
-- Name: nonces nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nonces
    ADD CONSTRAINT nonces_pkey PRIMARY KEY (token);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token_hash);


--
-- Name: idx_accounts_attributes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_attributes_name ON public.accounts USING gin (((attributes -> 'name'::text)));


--
-- Name: idx_accounts_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_email ON public.accounts USING btree (email);


--
-- Name: idx_accounts_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_phone ON public.accounts USING btree (phone);


--
-- Name: idx_accounts_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_accounts_username ON public.accounts USING btree (username);


--
-- Name: idx_buckets_attributes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_buckets_attributes ON public.buckets USING gin (attributes);


--
-- Name: idx_delegations_authorization_code_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_authorization_code_hash ON public.delegations USING btree (authorization_code_hash);


--
-- Name: idx_delegations_client_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_client_id ON public.delegations USING btree (client_id);


--
-- Name: idx_delegations_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_expires ON public.delegations USING btree (expires);


--
-- Name: idx_delegations_owner; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_owner ON public.delegations USING btree (owner);


--
-- Name: idx_delegations_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delegations_status ON public.delegations USING btree (status);


--
-- Name: idx_devices_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_devices_account_id ON public.devices USING btree (account_id);


--
-- Name: idx_devices_device_id_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_devices_device_id_account_id ON public.devices USING btree (device_id, account_id);


--
-- Name: idx_drc_attributes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drc_attributes ON public.dynamically_registered_clients USING gin (attributes);


--
-- Name: idx_drc_instance_of_client; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_drc_instance_of_client ON public.dynamically_registered_clients USING btree (instance_of_client);


--
-- Name: idx_linked_accounts_accounts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_linked_accounts_accounts_id ON public.linked_accounts USING btree (account_id);


--
-- Name: idx_sessions_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_id ON public.sessions USING btree (id);


--
-- Name: idx_sessions_id_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_id_expires ON public.sessions USING btree (id, expires);


--
-- Name: idx_tokens_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_expires ON public.tokens USING btree (expires);


--
-- Name: idx_tokens_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_id ON public.tokens USING btree (id);


--
-- Name: idx_tokens_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_status ON public.tokens USING btree (status);


--
-- PostgreSQL database dump complete
--


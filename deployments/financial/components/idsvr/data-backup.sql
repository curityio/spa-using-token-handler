
-- While Postgres has native support for UUID's, an extension is needed for generating them.
-- This extension comes bundled with most installations of Postgres but if not must be installed separately
--
-- https://dba.stackexchange.com/questions/122623/default-value-for-uuid-column-in-postgres
--
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


/* Token Store : table delegations */

CREATE TABLE delegations (
  id                          VARCHAR(40)   PRIMARY KEY,
  owner                       VARCHAR(128)  NOT NULL,
  created                     BIGINT        NOT NULL,
  expires                     BIGINT        NOT NULL,
  scope                       VARCHAR(1000) NULL,
  scope_claims                TEXT          NULL,
  client_id                   VARCHAR(128)  NOT NULL,
  redirect_uri                VARCHAR(512)  NULL,
  status                      VARCHAR(16)   NOT NULL,
  claims                      TEXT          NULL,
  authentication_attributes   TEXT          NULL,
  authorization_code_hash     VARCHAR(89)   NULL
);

CREATE INDEX IDX_DELEGATIONS_CLIENT_ID               ON delegations (client_id ASC);
CREATE INDEX IDX_DELEGATIONS_STATUS                  ON delegations (status ASC);
CREATE INDEX IDX_DELEGATIONS_EXPIRES                 ON delegations (expires ASC);
CREATE INDEX IDX_DELEGATIONS_OWNER                   ON delegations (owner ASC);
CREATE INDEX IDX_DELEGATIONS_AUTHORIZATION_CODE_HASH ON delegations (authorization_code_hash ASC);

COMMENT ON COLUMN delegations.id IS 'Unique identifier';
COMMENT ON COLUMN delegations.owner IS 'Subject for whom the delegation is issued';
COMMENT ON COLUMN delegations.expires IS 'Moment when delegation expires, as measured in number of seconds since epoch';
COMMENT ON COLUMN delegations.scope IS 'Space delimited list of scope values';
COMMENT ON COLUMN delegations.scope_claims IS 'JSON with the scope-claims configuration at the time of delegation issuance';
COMMENT ON COLUMN delegations.client_id IS 'Reference to a client; non-enforced';
COMMENT ON COLUMN delegations.redirect_uri IS 'Optional value for the redirect_uri parameter, when provided in a request for delegation';
COMMENT ON COLUMN delegations.status IS 'Status of the delegation instance, from {''issued'', ''revoked''}';
COMMENT ON COLUMN delegations.claims IS 'Optional JSON that contains a list of claims that are part of the delegation';
COMMENT ON COLUMN delegations.authentication_attributes IS 'The JSON-serialized AuthenticationAttributes established for this delegation';
COMMENT ON COLUMN delegations.authorization_code_hash IS 'A hash of the authorization code that was provided when this delegation was issued.';


/* Token Store : table tokens */

CREATE TABLE tokens (
  token_hash     VARCHAR(89)  NOT NULL PRIMARY KEY,
  id             VARCHAR(64)  NULL,
  delegations_id VARCHAR(40)  NOT NULL ,
  purpose        VARCHAR(32)  NOT NULL,
  usage          VARCHAR(8)   NOT NULL,
  format         VARCHAR(32)  NOT NULL,
  created        BIGINT       NOT NULL,
  expires        BIGINT       NOT NULL,
  scope          VARCHAR(1000)NULL,
  scope_claims   TEXT         NULL,
  status         VARCHAR(16)  NOT NULL,
  issuer         VARCHAR(200) NOT NULL,
  subject        VARCHAR(64)  NOT NULL,
  audience       VARCHAR(512) NULL,
  not_before     BIGINT       NULL,
  claims         TEXT         NULL,
  meta_data      TEXT         NULL
);

CREATE INDEX IDX_TOKENS_ID      ON tokens (id);
CREATE INDEX IDX_TOKENS_STATUS  ON tokens (status ASC);
CREATE INDEX IDX_TOKENS_EXPIRES ON tokens (expires ASC);

COMMENT ON COLUMN tokens.token_hash IS 'Base64 encoded sha-512 hash of the token value.';
COMMENT ON COLUMN tokens.id IS 'Identifier of the token, when it exists; this can be the value from the ''jti''-claim of a JWT, etc. Opaque tokens do not have an id.';
COMMENT ON COLUMN tokens.delegations_id IS 'Reference to the delegation instance that underlies the token';
COMMENT ON COLUMN tokens.purpose IS 'Purpose of the token, i.e. ''nonce'', ''accesstoken'', ''refreshtoken'', ''custom'', etc.';
COMMENT ON COLUMN tokens.usage IS 'Indication whether the token is a bearer or proof token, from {"bearer", "proof"}';
COMMENT ON COLUMN tokens.format IS 'The format of the token, i.e. ''opaque'', ''jwt'', etc.';
COMMENT ON COLUMN tokens.created IS 'Moment when token record is created, as measured in number of seconds since epoch';
COMMENT ON COLUMN tokens.expires IS 'Moment when token expires, as measured in number of seconds since epoch';
COMMENT ON COLUMN tokens.scope IS 'Space delimited list of scope values';
COMMENT ON COLUMN tokens.scope_claims IS 'Space delimited list of scope-claims values';
COMMENT ON COLUMN tokens.status IS 'Status of the token from {''issued'', ''used'', ''revoked''}';
COMMENT ON COLUMN tokens.issuer IS 'Optional name of the issuer of the token (jwt.iss)';
COMMENT ON COLUMN tokens.subject IS 'Optional subject of the token (jwt.sub)';
COMMENT ON COLUMN tokens.audience IS 'Space separated list of audiences for the token (jwt.aud)';
COMMENT ON COLUMN tokens.not_before IS 'Moment before which the token is not valid, as measured in number of seconds since epoch (jwt.nbf)';
COMMENT ON COLUMN tokens.claims IS 'Optional JSON-blob that contains a list of claims that are part of the token';


CREATE TABLE nonces (
  token           VARCHAR(64) NOT NULL PRIMARY KEY,
  reference_data  TEXT        NOT NULL,
  created         BIGINT      NOT NULL,
  ttl             BIGINT      NOT NULL,
  consumed        BIGINT      NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'issued'
);

COMMENT ON COLUMN nonces.token IS 'Value issued as random nonce';
COMMENT ON COLUMN nonces.reference_data IS 'Value that is referenced by the nonce value';
COMMENT ON COLUMN nonces.created IS 'Moment when nonce record is created, as measured in number of seconds since epoch';
COMMENT ON COLUMN nonces.ttl IS 'Time To Live, period in seconds since created after which the nonce expires';
COMMENT ON COLUMN nonces.consumed IS 'Moment when nonce was consumed, as measured in number of seconds since epoch';
COMMENT ON COLUMN nonces.status IS 'Status of the nonce from {''issued'', ''revoked'', ''used''}';


CREATE TABLE accounts (
  account_id  VARCHAR(64)   PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
  tenant_id   VARCHAR(64),
  username    VARCHAR(64)   NOT NULL,
  password    VARCHAR(128),
  email       VARCHAR(64),
  phone       VARCHAR(32),
  attributes  JSONB,
  active      SMALLINT      NOT NULL DEFAULT 0,
  created     BIGINT        NOT NULL,
  updated     BIGINT        NOT NULL
);

CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_USERNAME ON accounts (tenant_id, username);
CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_PHONE    ON accounts (tenant_id, phone);
CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_EMAIL    ON accounts (tenant_id, email);

-- Indexes enforcing uniqueness of username, phone, email for default tenant.
CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_USERNAME_DEFAULT ON accounts(username) WHERE tenant_id IS NULL;
CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_PHONE_DEFAULT ON accounts(phone) WHERE tenant_id IS NULL;
CREATE UNIQUE INDEX IDX_ACCOUNTS_TENANT_EMAIL_DEFAULT ON accounts(email) WHERE tenant_id IS NULL;

CREATE INDEX IDX_ACCOUNTS_ATTRIBUTES_NAME ON accounts USING GIN ( (attributes->'name') );

COMMENT ON COLUMN accounts.account_id IS 'Account id, or username, of this account. Unique.';
COMMENT ON COLUMN accounts.tenant_id IS 'The tenant ID of this account. Unique in combination with username, phone, email.';
COMMENT ON COLUMN accounts.username IS 'The username of this account. Unique in combination with tenant_id.';
COMMENT ON COLUMN accounts.password IS 'The hashed password. Optional';
COMMENT ON COLUMN accounts.email IS 'The associated email address. Unique in combination with tenant_id. Optional';
COMMENT ON COLUMN accounts.phone IS 'The phone number of the account owner. Unique in combination with tenant_id. Optional';
COMMENT ON COLUMN accounts.attributes IS 'Key/value map of additional attributes associated with the account.';
COMMENT ON COLUMN accounts.active IS 'Indicates if this account has been activated or not. Activation is usually via email or sms.';
COMMENT ON COLUMN accounts.created IS 'Time since epoch of account creation, in seconds';
COMMENT ON COLUMN accounts.updated IS 'Time since epoch of latest account update, in seconds';


CREATE TABLE linked_accounts (
  account_id                  VARCHAR(64) NOT NULL,
  tenant_id                   VARCHAR(64),
  linked_account_id           VARCHAR(64) NOT NULL,
  linked_account_domain_name  VARCHAR(64) NOT NULL,
  linking_account_manager     VARCHAR(128),
  created                     TIMESTAMP   NOT NULL,

  PRIMARY KEY (account_id, linked_account_id, linked_account_domain_name)
);

CREATE UNIQUE INDEX IDX_LINKED_ACCOUNTS_TENANT_ACCOUNT_DOMAIN ON linked_accounts (tenant_id, linked_account_id, linked_account_domain_name);
CREATE UNIQUE INDEX IDX_LINKED_ACCOUNTS_TENANT_ACCOUNT_DOMAIN_DEFAULT ON linked_accounts (linked_account_id, linked_account_domain_name) WHERE tenant_id IS NULL;

COMMENT ON COLUMN linked_accounts.account_id IS 'Account ID, typically a global one, of the account being linked from (the linker)';
COMMENT ON COLUMN linked_accounts.tenant_id IS 'The tenant ID of this linked account';
COMMENT ON COLUMN linked_accounts.linked_account_id IS 'Account ID, typically a local or legacy one, of the account being linked (the linkee)';
COMMENT ON COLUMN linked_accounts.linked_account_domain_name IS 'The domain (i.e., organizational group or realm) of the account being linked';


CREATE TABLE credentials (
  id          VARCHAR(36)  PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   VARCHAR(64),
  subject     VARCHAR(64)  NOT NULL,
  password    VARCHAR(128) NOT NULL,
  attributes  JSONB        NOT NULL,
  created     TIMESTAMP    NOT NULL,
  updated     TIMESTAMP    NOT NULL
);

CREATE UNIQUE INDEX IDX_CREDENTIALS_TENANT_SUBJECT ON credentials (tenant_id, subject);
CREATE UNIQUE INDEX IDX_CREDENTIALS_TENANT_SUBJECT_DEFAULT ON credentials (subject) WHERE tenant_id IS NULL;

COMMENT ON COLUMN credentials.id IS 'ID of this credential (unique)';
COMMENT ON COLUMN credentials.tenant_id IS 'The tenant ID of this credential';
COMMENT ON COLUMN credentials.subject IS 'The subject of this credential (unique to a tenant)';
COMMENT ON COLUMN credentials.password IS 'The hashed password';
COMMENT ON COLUMN credentials.attributes IS 'Key/value map of additional attributes associated with the credential';
COMMENT ON COLUMN credentials.created IS 'When this credential was created';
COMMENT ON COLUMN credentials.updated IS 'When this credential was last updated';


CREATE TABLE sessions (
  id            VARCHAR(64) NOT NULL PRIMARY KEY,
  session_data  TEXT        NOT NULL,
  expires       BIGINT      NOT NULL
);

CREATE INDEX IDX_SESSIONS_ID         ON sessions (id ASC);
CREATE INDEX IDX_SESSIONS_ID_EXPIRES ON sessions (id, expires);


COMMENT ON COLUMN sessions.id IS 'id given to the session';
COMMENT ON COLUMN sessions.session_data IS 'Value that is referenced by the session id';
COMMENT ON COLUMN sessions.expires IS 'Moment when session record expires, as measured in number of seconds since epoch';


CREATE TABLE devices (
  id          VARCHAR(64) PRIMARY KEY NOT NULL,
  device_id   VARCHAR(256),
  tenant_id   VARCHAR(64),
  account_id  VARCHAR(256),
  external_id VARCHAR(32),
  alias       VARCHAR(30),
  form_factor VARCHAR(10),
  device_type VARCHAR(50),
  owner       VARCHAR(256),
  attributes  JSONB,
  expires     BIGINT,
  created     BIGINT      NOT NULL,
  updated     BIGINT      NOT NULL
);

CREATE UNIQUE INDEX IDX_DEVICES_TENANT_ACCOUNT_ID_DEVICE_ID ON devices (tenant_id, account_id ASC, device_id ASC);
CREATE UNIQUE INDEX IDX_DEVICES_TENANT_ACCOUNT_ID_DEVICE_ID_DEFAULT  ON devices (account_id ASC, device_id ASC) WHERE tenant_id IS NULL;
CREATE INDEX IDX_DEVICE_ID ON devices (device_id ASC);

COMMENT ON COLUMN devices.id IS 'Unique ID of the device';
COMMENT ON COLUMN devices.device_id IS 'The device ID that identifies the physical device';
COMMENT ON COLUMN devices.tenant_id IS 'The tenant ID of this device';
COMMENT ON COLUMN devices.account_id IS 'The user account ID that is associated with the device';
COMMENT ON COLUMN devices.alias IS 'The user-recognizable name or mnemonic identifier of the device (e.g., my work iPhone)';
COMMENT ON COLUMN devices.form_factor IS 'The type or form of device (e.g., laptop, phone, tablet, etc.)';
COMMENT ON COLUMN devices.device_type IS 'The device type (i.e., make, manufacturer, provider, class)';
COMMENT ON COLUMN devices.owner IS 'The owner of the device. This is the user who has administrative rights on the device';
COMMENT ON COLUMN devices.attributes IS 'Key/value map of custom attributes associated with the device.';
COMMENT ON COLUMN devices.expires IS 'Time since epoch of device expiration, in seconds';
COMMENT ON COLUMN devices.created IS 'Time since epoch of device creation, in seconds';
COMMENT ON COLUMN devices.updated IS 'Time since epoch of latest device update, in seconds';


-- This number is user-supplied and may not be a phone number. It can be a part number or employer-provided unit number.
-- It may also be blank. In any event, it is only used to provide the user with an extra queue as to which device this
-- one refers. Unlike the phone number in the account table, this one is _not_ verified in any way.
COMMENT ON COLUMN devices.external_id IS 'The phone or other identifying number of the device (if it has one)';


CREATE TABLE audit (
  id                    VARCHAR(64)   PRIMARY KEY,
  instant               TIMESTAMP     NOT NULL,
  event_instant         VARCHAR(64)   NOT NULL,
  server                VARCHAR(255)  NOT NULL,
  message               TEXT          NOT NULL,
  event_type            VARCHAR(48)   NOT NULL,
  subject               VARCHAR(128),
  client                VARCHAR(128),
  resource              VARCHAR(128),
  authenticated_subject VARCHAR(128),
  authenticated_client  VARCHAR(128),
  acr                   VARCHAR(128),
  endpoint              VARCHAR(255),
  session               VARCHAR(128)
);

COMMENT ON COLUMN audit.id IS 'Unique ID of the log message';
COMMENT ON COLUMN audit.instant IS 'Moment that the event was logged';
COMMENT ON COLUMN audit.event_instant IS 'Moment that the event occurred';
COMMENT ON COLUMN audit.server IS 'The server node where the event occurred';
COMMENT ON COLUMN audit.message IS 'Message describing the event';
COMMENT ON COLUMN audit.event_type IS 'Type of event that the message is about';
COMMENT ON COLUMN audit.subject IS 'The subject (i.e., user) effected by the event';
COMMENT ON COLUMN audit.client IS 'The client ID effected by the event';
COMMENT ON COLUMN audit.resource IS 'The resource ID effected by the event';
COMMENT ON COLUMN audit.authenticated_subject IS 'The authenticated subject (i.e., user) effected by the event';
COMMENT ON COLUMN audit.authenticated_client IS 'The authenticated client effected by the event';
COMMENT ON COLUMN audit.acr IS 'The ACR used to authenticate the subject (i.e., user)';
COMMENT ON COLUMN audit.endpoint IS 'The endpoint where the event was triggered';
COMMENT ON COLUMN audit.session IS 'The session ID in which the event was triggered';


CREATE TABLE dynamically_registered_clients (
  client_id           VARCHAR(64)     NOT NULL PRIMARY KEY,
  client_secret       VARCHAR(128),
  instance_of_client  VARCHAR(64)     NULL,
  created             TIMESTAMP       NOT NULL,
  updated             TIMESTAMP       NOT NULL,
  initial_client      VARCHAR(64)     NULL,
  authenticated_user  VARCHAR(64)     NULL,
  attributes          JSONB           NOT NULL DEFAULT '{}',
  status              VARCHAR(12)     NOT NULL DEFAULT 'active',
  scope               TEXT            NULL,
  redirect_uris       TEXT            NULL,
  grant_types         VARCHAR(500)    NULL
);

CREATE INDEX IDX_DRC_INSTANCE_OF_CLIENT        ON dynamically_registered_clients(instance_of_client);
CREATE INDEX IDX_DRC_ATTRIBUTES                ON dynamically_registered_clients USING GIN (attributes);
CREATE INDEX IDX_DRC_CREATED                   ON dynamically_registered_clients(created);
CREATE INDEX IDX_DRC_STATUS                    ON dynamically_registered_clients(status);
CREATE INDEX IDX_DRC_AUTHENTICATED_USER        ON dynamically_registered_clients(authenticated_user);

COMMENT ON COLUMN dynamically_registered_clients.client_id IS 'The client ID of this client instance';
COMMENT ON COLUMN dynamically_registered_clients.created IS 'When this client was originally created (in UTC time)';
COMMENT ON COLUMN dynamically_registered_clients.updated IS 'When this client was last updated (in UTC time)';
COMMENT ON COLUMN dynamically_registered_clients.initial_client IS 'In case the user authenticated, this value contains a client_id value of the initial token. If the initial token was issued through a client credentials-flow, the initial_client value is set to the client that authenticated. Registration without initial token (i.e. with no authentication) will result in a null value for initial_client';
COMMENT ON COLUMN dynamically_registered_clients.authenticated_user IS 'In case a user authenticated (through a client), this value contains the sub value of the initial token';
COMMENT ON COLUMN dynamically_registered_clients.attributes IS 'Arbitrary attributes tied to this client';
COMMENT ON COLUMN dynamically_registered_clients.status IS 'The current status of the client, allowed values are "active", "inactive" and "revoked"';
COMMENT ON COLUMN dynamically_registered_clients.scope IS 'Space separated list of scopes defined for this client (non-templatized clients only)';
COMMENT ON COLUMN dynamically_registered_clients.redirect_uris IS 'Space separated list of redirect URI''s defined for this client (non-templatized clients only)';
COMMENT ON COLUMN dynamically_registered_clients.grant_types IS 'Space separated list of grant types defined for this client (non-templatized clients only)';

CREATE TABLE database_clients
(
    client_id                                                 VARCHAR(64)  NOT NULL,
    profile_id                                                VARCHAR(64)  NOT NULL,
    client_name                                               VARCHAR(128) NULL,
    created                                                   TIMESTAMP    NOT NULL,
    updated                                                   TIMESTAMP    NOT NULL,
    owner                                                     VARCHAR(128) NOT NULL,
    status                                                    VARCHAR(16)  NOT NULL DEFAULT 'active',
    client_metadata                                           JSONB        NOT NULL DEFAULT '{}',
    configuration_references                                  JSONB        NOT NULL DEFAULT '{}',
    attributes                                                JSONB        NOT NULL DEFAULT '{}',

    PRIMARY KEY (client_id, profile_id)
);

COMMENT ON COLUMN database_clients.client_id IS 'The client ID of this client instance';
COMMENT ON COLUMN database_clients.profile_id IS 'The profile ID owning this client instance';
COMMENT ON COLUMN database_clients.client_name IS 'The optional database client display name';
COMMENT ON COLUMN database_clients.created IS 'When this client was originally created (in UTC time)';
COMMENT ON COLUMN database_clients.updated IS 'When this client was last updated (in UTC time)';
COMMENT ON COLUMN database_clients.owner IS 'The owner of the database client. This is the user or client who has administrative rights on the database client';
COMMENT ON COLUMN database_clients.status IS 'The current status of the client, allowed values are "active", "inactive" and "revoked"';
COMMENT ON COLUMN database_clients.client_metadata IS 'Metadata, as a JSON document, tied to this client, especially tags categorizing it';
COMMENT ON COLUMN database_clients.configuration_references IS 'JSON document with all attributes referencing an item in the configuration';
COMMENT ON COLUMN database_clients.attributes IS 'Canonical object representing this client';

CREATE INDEX IDX_DATABASE_CLIENTS_PROFILE_ID ON database_clients (profile_id ASC);
CREATE INDEX IDX_DATABASE_CLIENTS_CLIENT_NAME ON database_clients (client_name ASC);
CREATE INDEX IDX_DATABASE_CLIENTS_OWNER ON database_clients (owner ASC);
CREATE INDEX IDX_DATABASE_CLIENTS_METADATA_TAGS ON database_clients USING GIN ((client_metadata -> 'tags') jsonb_path_ops);
CREATE INDEX IDX_DATABASE_CLIENTS_METADATA_TAGS_NULL ON database_clients (client_metadata) WHERE client_metadata->'tags' IS NULL;

CREATE TABLE buckets (
    id         VARCHAR(64)  NOT NULL DEFAULT uuid_generate_v4(),
    subject    VARCHAR(128) NOT NULL,
    purpose    VARCHAR(64)  NOT NULL,
    tenant_id  VARCHAR(64),
    attributes JSONB        NOT NULL,
    created    TIMESTAMP    NOT NULL,
    updated    TIMESTAMP    NOT NULL,

    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IDX_BUCKETS_TENANT_SUBJECT_PURPOSE on buckets (tenant_id, subject, purpose);
CREATE UNIQUE INDEX IDX_BUCKETS_TENANT_SUBJECT_PURPOSE_DEFAULT on buckets (subject, purpose) WHERE tenant_id IS NULL;

CREATE INDEX IDX_BUCKETS_ATTRIBUTES ON buckets USING GIN (attributes);

COMMENT ON COLUMN buckets.id IS 'Unique ID of the bucket';
COMMENT ON COLUMN buckets.subject IS 'The subject that together with the purpose identify this bucket';
COMMENT ON COLUMN buckets.purpose IS 'The purpose of this bucket, eg. "login_attempt_counter"';
COMMENT ON COLUMN buckets.tenant_id IS 'The tenant ID of this bucket';
COMMENT ON COLUMN buckets.attributes IS 'All attributes stored for this subject/purpose';
COMMENT ON COLUMN buckets.created IS 'When this bucket was created';
COMMENT ON COLUMN buckets.updated IS 'When this bucket was last updated';

--
-- Restore the test user account and its password credential
--

COPY accounts (account_id, username, password, email, phone, attributes, active, created, updated) FROM stdin;
79b6852c-8062-403b-b0a9-3b19d7175233	demouser	\N	demo@user.com	07711	{"name": {"givenName": "Demo", "familyName": "User"}, "emails": [{"value": "demo@user.com", "primary": true}], "agreeToTerms": "on", "phoneNumbers": [{"value": "07711", "primary": true}], "urn:se:curity:scim:2.0:Devices": []}	1	1708008810	1708008810
\.

COPY credentials (id, subject, password, attributes, created, updated) FROM stdin;
6a273e20-6015-4243-8117-44379cadf582	demouser	$5$rounds=20000$p32Fp4ecezzC0BSk$kaqe1ol1ShkqespXd9QiX.NNRasd0nOOQiC6ES1wOiB	{}	2024-02-15 14:53:30.623009	2024-02-15 14:53:30.623009
\.

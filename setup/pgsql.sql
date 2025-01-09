\o /dev/null
-- Uncomment the following block if you want this script to create
-- the database for you and set up its access.
-- Don't forget to change the password (currently: CHANGE).
-- You may also change the database and user names if you want.
-- Note that if changing the user name, you should also update ALTER TABLE
-- queries that set table owner.

/*
    CREATE USER vexim WITH PASSWORD 'CHANGE' NOCREATEDB NOSUPERUSER;
    CREATE DATABASE vexim WITH ENCODING 'UTF8' OWNER vexim;
    \c vexim;
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- */

-- When adding the siteadmin user, we will hash that user's password using
-- the hashing scheme specified below. Note that MD5 hashes are not secure
-- (easy to crack), so you should definitely change your password when you
-- first login. You may even "change" the password to the same one, just to
-- trigger a re-hash. Alternatively, if you are using *BSD or Solaris, you
-- may change the setting below to 'bf' to use a much more secure bcrypt
-- scheme right from the start:

SELECT SET_CONFIG('vexim.site_admin_pw_scheme', 'md5', false);

-- No further changes should be made to this script.

SET NAMES 'UTF8';

--
-- Drop existing tables. Disabling foreign key checks is more difficult
-- with PostgreSQL than with MySQL, so we'll just drop all tables in a
-- correct order.
--

DROP TABLE IF EXISTS "group_contents";
DROP TABLE IF EXISTS "groups";
DROP TABLE IF EXISTS "blocklists";
DROP TABLE IF EXISTS "users";
DROP TABLE IF EXISTS "domainalias";
DROP TABLE IF EXISTS "domains";

--
-- Table structure for table "domains"
--

CREATE TABLE "domains" (
  "domain_id" SERIAL PRIMARY KEY,
  "domain" varchar(255) UNIQUE NOT NULL default '',
  "maildir" varchar(4096) NOT NULL default '',
  "uid" int NOT NULL default '65534' CHECK("uid" BETWEEN 1 AND 65535),
  "gid" int NOT NULL default '65534' CHECK("gid" BETWEEN 1 AND 65535),
  "max_accounts" int NOT NULL default '0' CHECK("max_accounts" > -1),
  "quotas" int NOT NULL default '0' CHECK("quotas" > -1),
  "type" varchar(5) default NULL,
  "avscan" smallint NOT NULL default '0' CHECK("avscan" BETWEEN 0 AND 1),
  "blocklists" smallint NOT NULL default '0' CHECK("blocklists" BETWEEN 0 AND 1),
  "enabled" smallint NOT NULL default '1' CHECK("enabled" BETWEEN 0 AND 1),
  "mailinglists" smallint NOT NULL default '0' CHECK("mailinglists" BETWEEN 0 AND 1),
  "maxmsgsize" int NOT NULL default '0' CHECK("maxmsgsize" > -1),
  "pipe" smallint NOT NULL default '0' CHECK("pipe" BETWEEN 0 AND 1),
  "spamassassin" smallint NOT NULL default '0' CHECK("spamassassin" BETWEEN 0 AND 1),
  "sa_tag" int NOT NULL default '0' CHECK("sa_tag" > -1),
  "sa_refuse" int NOT NULL default '0' CHECK("sa_refuse" > -1));
ALTER TABLE "domains" OWNER TO vexim;

--
-- Table structure for table "users"
--

CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "domain_id" int NOT NULL,
  "localpart" varchar(64) NOT NULL default '',
  "username" varchar(255) NOT NULL default '',
  "crypt" varchar(255) default NULL,
  "uid" int NOT NULL default '65534' CHECK("uid" BETWEEN 1 AND 65535),
  "gid" int NOT NULL default '65534' CHECK("gid" BETWEEN 1 AND 65535),
  "smtp" varchar(4096) default NULL,
  "pop" varchar(4096) default NULL,
  "type" varchar(8) CHECK("type" in ('local','alias','catch', 'fail', 'piped', 'admin', 'site')) NOT NULL,
  "admin" smallint NOT NULL default '0' CHECK("admin" BETWEEN 0 AND 1),
  "on_avscan" smallint NOT NULL default '0' CHECK("on_avscan" BETWEEN 0 AND 1),
  "on_blocklist" smallint NOT NULL default '0' CHECK("on_blocklist" BETWEEN 0 AND 1),
  "on_forward" smallint NOT NULL default '0' CHECK("on_forward" BETWEEN 0 AND 1),
  "on_piped" smallint NOT NULL default '0' CHECK("on_piped" BETWEEN 0 AND 1),
  "on_spamassassin" smallint NOT NULL default '0' CHECK("on_spamassassin" BETWEEN 0 AND 1),
  "on_vacation" smallint NOT NULL default '0' CHECK("on_vacation" BETWEEN 0 AND 1),
  "spam_drop" smallint NOT NULL default '0' CHECK("spam_drop" BETWEEN 0 AND 1),
  "enabled" smallint NOT NULL default '1' CHECK("enabled" BETWEEN 0 AND 1),
  "flags" varchar(16) default NULL,
  "forward" varchar(4096) default NULL,
  "unseen" smallint NOT NULL default '0' CHECK("unseen" BETWEEN 0 AND 1),
  "maxmsgsize" int NOT NULL default '0' CHECK("maxmsgsize" > -1),
  "quota" int NOT NULL default '0' CHECK("quota" > -1),
  "realname" varchar(255) default NULL,
  "sa_tag" smallint NOT NULL default '0' CHECK("sa_tag" > -1),
  "sa_refuse" smallint NOT NULL default '0' CHECK("sa_refuse" > -1),
  "tagline" varchar(255) default NULL,
  "vacation" text default NULL,
  UNIQUE ("localpart","domain_id"));
CREATE INDEX "local" ON "users" ("localpart");
CREATE INDEX "fk_users_domain_id_idx" ON "users" ("domain_id");
ALTER TABLE "users"
  ADD CONSTRAINT "fk_users_domain_id"
  FOREIGN KEY ("domain_id")
  REFERENCES "domains" ("domain_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "users" OWNER TO vexim;

--
-- Table structure for table "blocklists"
--

CREATE TABLE "blocklists" (
  "block_id" SERIAL PRIMARY KEY,
  "domain_id" int NOT NULL,
  "user_id" int NOT NULL,
  "blockhdr" varchar(192) NOT NULL default '',
  "blockval" varchar(255) NOT NULL default '',
  "color" varchar(8) NOT NULL default '');
CREATE INDEX "fk_blocklists_domain_id_idx" ON "blocklists" ("domain_id");
CREATE INDEX "fk_blocklists_user_id_idx" ON "blocklists" ("user_id");
ALTER TABLE "blocklists"
  ADD CONSTRAINT "fk_blocklists_domain_id"
  FOREIGN KEY ("domain_id")
  REFERENCES "domains" ("domain_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "blocklists"
  ADD CONSTRAINT "fk_blocklists_user_id"
  FOREIGN KEY ("user_id")
  REFERENCES "users" ("user_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "blocklists" OWNER TO vexim;

--
-- Table structure for table "domainalias"
--

CREATE TABLE domainalias (
  domain_id int NOT NULL,
  alias varchar(255) NOT NULL PRIMARY KEY);
CREATE INDEX "fk_domainalias_domain_id_idx" ON "domainalias" ("domain_id");
ALTER TABLE "domainalias"
  ADD CONSTRAINT "fk_domainalias_domain_id"
  FOREIGN KEY ("domain_id")
  REFERENCES "domains" ("domain_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "domainalias" OWNER TO vexim;

--
-- Table structure for table "groups"
--

CREATE TABLE "groups" (
  "id" SERIAL PRIMARY KEY,
  "domain_id" int NOT NULL,
  "name" varchar(64) NOT NULL,
  "is_public" char(1) NOT NULL DEFAULT 'Y',
  "enabled" smallint NOT NULL DEFAULT '1' CHECK("enabled" BETWEEN 0 AND 1),
  UNIQUE("domain_id","name"));
CREATE INDEX "fk_groups_domain_id_idx" ON "groups" ("domain_id");
ALTER TABLE "groups"
  ADD CONSTRAINT "fk_groups_domain_id"
  FOREIGN KEY ("domain_id")
  REFERENCES "domains" ("domain_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "groups" OWNER TO vexim;

--
-- Table structure for table "group_contents"
--

CREATE TABLE "group_contents" (
  "group_id" int NOT NULL,
  "member_id" int NOT NULL,
  PRIMARY KEY ("group_id","member_id"));
CREATE INDEX "fk_group_contents_group_id_idx" ON "group_contents" ("group_id");
CREATE INDEX "fk_group_contents_member_id_idx" ON "group_contents" ("member_id");
ALTER TABLE "group_contents"
  ADD CONSTRAINT "fk_group_contents_group_id"
  FOREIGN KEY ("group_id")
  REFERENCES "groups" ("id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "group_contents"
  ADD CONSTRAINT "fk_group_contents_member_id"
  FOREIGN KEY ("member_id")
  REFERENCES "users" ("user_id")
  ON DELETE CASCADE
  ON UPDATE CASCADE
  DEFERRABLE
  INITIALLY DEFERRED;
ALTER TABLE "group_contents" OWNER TO vexim;

--
-- Seed the `domains` table with the hidden siteadmin domain
--
INSERT INTO "domains" VALUES (1,'admin','',65534,65534,0,0,NULL,0,0,1,0,0,0,0,0,0);

--
-- Generate and hash password for siteadmin if pgcrypto is available
--

SELECT SET_CONFIG('vexim.site_admin_pw', ARRAY_TO_STRING(ARRAY(SELECT SUBSTR('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',TRUNC(RANDOM()*62)::INTEGER+1,1) FROM GENERATE_SERIES(1,10)),''), false)
  FROM "pg_available_extensions"
  WHERE "name"='pgcrypto' AND "installed_version" IS NOT NULL;
SELECT SET_CONFIG('vexim.site_admin_pw_hash', CRYPT(CURRENT_SETTING('vexim.site_admin_pw'), GEN_SALT(CURRENT_SETTING('vexim.site_admin_pw_scheme'))), false)
  FROM "pg_available_extensions"
  WHERE "name"='pgcrypto' AND "installed_version" IS NOT NULL;

--
-- Otherwise, if pgcrypto is unavailable and thus we can't hash the password, use the default one
--

SELECT SET_CONFIG('vexim.site_admin_pw', 'CHANGE', false)
  FROM "pg_available_extensions"
  WHERE "name"='pgcrypto' AND "installed_version" IS NULL;
SELECT SET_CONFIG('vexim.site_admin_pw_hash', '$1$12345678$2lQK5REWxaFyGz.p/dos3/', false)
  FROM "pg_available_extensions"
  WHERE "name"='pgcrypto' AND "installed_version" IS NULL;

--
-- Seed the `users` table with the siteadmin user
--

INSERT INTO "users" VALUES (1,1,'siteadmin','siteadmin',CURRENT_SETTING('vexim.site_admin_pw_hash'),65535,65535,'','','site',1,0,0,0,0,0,0,0,1,NULL,NULL,0,0,0,'SiteAdmin',0,0,NULL,NULL);

--
-- Reset auto-increment values
--

SELECT SETVAL('domains_domain_id_seq', COALESCE(MAX("domain_id"), 1) ) FROM "domains";
SELECT SETVAL('users_user_id_seq', COALESCE(MAX("user_id"), 1) ) FROM "users";
SELECT SETVAL('blocklists_block_id_seq', COALESCE(MAX("block_id"), 1) ) FROM "blocklists";
SELECT SETVAL('groups_id_seq', COALESCE(MAX("id"), 1) ) FROM "groups";

--
-- Drop the pgcrypto extension – we won't be needing it anymore.
--

DROP EXTENSION IF EXISTS pgcrypto;

--
-- Output siteadmin credentials
--
\pset footer off
\o
\echo
\echo
\echo

SELECT '
A site administrator account has been created with the following credentials:

User name:   siteadmin
Password:    ' || CURRENT_SETTING('vexim.site_admin_pw') || '

You are encouraged to change this password to an even more secure one though. 

' AS "DATABASE SETUP COMPLETE";

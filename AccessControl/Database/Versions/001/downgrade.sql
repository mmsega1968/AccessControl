-- Downgrade 001 — удаление схемы и таблиц AEAM

-- 1. Удаление таблиц в правильном порядке (учёт внешних ключей)

DROP TABLE IF EXISTS {{schema}}.role_includes;
DROP TABLE IF EXISTS {{schema}}.role_rights;
DROP TABLE IF EXISTS {{schema}}.user_roles;

DROP TABLE IF EXISTS {{schema}}.rights;
DROP TABLE IF EXISTS {{schema}}.roles;
DROP TABLE IF EXISTS {{schema}}.users;

-- 2. Таблица версий
DROP TABLE IF EXISTS {{schema}}.db_version;

-- 3. Удаление схемы
DROP SCHEMA IF EXISTS {{schema}} CASCADE;

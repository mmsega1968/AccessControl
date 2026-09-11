-- Version 001 — создание схемы и таблиц AEAM

-- 1. Схема
CREATE SCHEMA IF NOT EXISTS {{schema}};

-- 2. Таблицы

CREATE TABLE IF NOT EXISTS {{schema}}.users (
    id UUID PRIMARY KEY,
    username TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS {{schema}}.roles (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS {{schema}}.rights (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS {{schema}}.user_roles (
    user_id UUID NOT NULL REFERENCES {{schema}}.users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES {{schema}}.roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS {{schema}}.role_rights (
    role_id UUID NOT NULL REFERENCES {{schema}}.roles(id) ON DELETE CASCADE,
    right_id UUID NOT NULL REFERENCES {{schema}}.rights(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, right_id)
);

CREATE TABLE IF NOT EXISTS {{schema}}.role_includes (
    parent_role_id UUID NOT NULL REFERENCES {{schema}}.roles(id) ON DELETE CASCADE,
    child_role_id UUID NOT NULL REFERENCES {{schema}}.roles(id) ON DELETE CASCADE,
    PRIMARY KEY (parent_role_id, child_role_id)
);

-- 3. Таблица версий
CREATE TABLE IF NOT EXISTS {{schema}}.db_version (
    version TEXT PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT now()
);

-- 4. Запись версии
INSERT INTO {{schema}}.db_version(version) VALUES ('001');

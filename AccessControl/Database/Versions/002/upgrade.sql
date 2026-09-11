-- Version 002 — таблицы внешних запросов для WebSocket‑клиентов

-- 1. Таблица внешних запросов
CREATE TABLE IF NOT EXISTS {{schema}}.external_requests (
    id UUID PRIMARY KEY,
    client_id TEXT NOT NULL,
    action TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'Pending', -- Pending, Sent, Completed, Expired
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Индекс для поиска запросов по клиенту и статусу
CREATE INDEX IF NOT EXISTS idx_external_requests_client_status
    ON {{schema}}.external_requests (client_id, status);

-- 2. Таблица ответов на внешние запросы
CREATE TABLE IF NOT EXISTS {{schema}}.external_request_responses (
    id UUID PRIMARY KEY,
    request_id UUID NOT NULL REFERENCES {{schema}}.external_requests(id) ON DELETE CASCADE,
    payload JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- Индекс для быстрого поиска ответа по request_id
CREATE INDEX IF NOT EXISTS idx_external_request_responses_request
    ON {{schema}}.external_request_responses (request_id);


CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id UUID NULL REFERENCES departments(id) ON DELETE SET NULL,
    status INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);




-- 3. Запись версии
INSERT INTO {{schema}}.db_version(version) VALUES ('002');

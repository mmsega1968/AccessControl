-- Downgrade 002 — удаление таблиц внешних запросов

DROP TABLE IF EXISTS {{schema}}.external_request_responses;
DROP TABLE IF EXISTS {{schema}}.external_requests;

DELETE FROM {{schema}}.db_version WHERE version = '002';

--
-- PostgreSQL database dump
--

\restrict NtZV7EvC8RDKCF0zUjBjBNanYmSPBdpL5h1GPpF9WKaPSqAVNeywsGtVBkh2z6F

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 18.4

-- Started on 2026-09-11 12:43:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16385)
-- Name: access; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA access;


ALTER SCHEMA access OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 33015)
-- Name: access_current_roles; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_current_roles (
    client_id text NOT NULL,
    username text NOT NULL,
    role_code text NOT NULL
);


ALTER TABLE access.access_current_roles OWNER TO postgres;

--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE access_current_roles; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_current_roles IS 'Текущие доступы к ролям';


--
-- TOC entry 231 (class 1259 OID 32991)
-- Name: access_request_actions; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_request_actions (
    action_id bigint NOT NULL,
    request_id bigint NOT NULL,
    target_username text NOT NULL,
    role_code text NOT NULL,
    action_type text NOT NULL,
    effective_from date NOT NULL,
    effective_to date
);


ALTER TABLE access.access_request_actions OWNER TO postgres;

--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE access_request_actions; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_request_actions IS 'Список действий внутри заявки для пользователя';


--
-- TOC entry 230 (class 1259 OID 32990)
-- Name: access_request_actions_action_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_request_actions_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_request_actions_action_id_seq OWNER TO postgres;

--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 230
-- Name: access_request_actions_action_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_request_actions_action_id_seq OWNED BY access.access_request_actions.action_id;


--
-- TOC entry 229 (class 1259 OID 32977)
-- Name: access_request_users; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_request_users (
    request_user_id bigint NOT NULL,
    request_id bigint NOT NULL,
    target_username text NOT NULL
);


ALTER TABLE access.access_request_users OWNER TO postgres;

--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE access_request_users; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_request_users IS 'Пользователи внутри заявки';


--
-- TOC entry 228 (class 1259 OID 32976)
-- Name: access_request_users_request_user_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_request_users_request_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_request_users_request_user_id_seq OWNER TO postgres;

--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 228
-- Name: access_request_users_request_user_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_request_users_request_user_id_seq OWNED BY access.access_request_users.request_user_id;


--
-- TOC entry 227 (class 1259 OID 32967)
-- Name: access_requests; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_requests (
    request_id bigint NOT NULL,
    client_id text NOT NULL,
    created_by text NOT NULL,
    approved_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    approved_at timestamp with time zone,
    status text NOT NULL,
    comment text
);


ALTER TABLE access.access_requests OWNER TO postgres;

--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE access_requests; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_requests IS 'Заявки на предоставление доступа';


--
-- TOC entry 226 (class 1259 OID 32966)
-- Name: access_requests_request_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_requests_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_requests_request_id_seq OWNER TO postgres;

--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 226
-- Name: access_requests_request_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_requests_request_id_seq OWNED BY access.access_requests.request_id;


--
-- TOC entry 246 (class 1259 OID 33094)
-- Name: access_rights; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_rights (
    client_id text NOT NULL,
    right_code text NOT NULL,
    right_name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    retired_at timestamp with time zone
);


ALTER TABLE access.access_rights OWNER TO postgres;

--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE access_rights; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_rights IS 'Справочник прав от клиента';


--
-- TOC entry 248 (class 1259 OID 33104)
-- Name: access_rights_history; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_rights_history (
    history_id bigint NOT NULL,
    client_id text NOT NULL,
    right_code text NOT NULL,
    change_type text NOT NULL,
    old_value text,
    new_value text,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.access_rights_history OWNER TO postgres;

--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE access_rights_history; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_rights_history IS 'История изменения справочника прав';


--
-- TOC entry 247 (class 1259 OID 33103)
-- Name: access_rights_history_history_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_rights_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_rights_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 247
-- Name: access_rights_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_rights_history_history_id_seq OWNED BY access.access_rights_history.history_id;


--
-- TOC entry 241 (class 1259 OID 33065)
-- Name: access_role_history; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_role_history (
    history_id bigint NOT NULL,
    client_id text NOT NULL,
    role_code text NOT NULL,
    change_type text NOT NULL,
    old_value text,
    new_value text,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.access_role_history OWNER TO postgres;

--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE access_role_history; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_role_history IS 'История ролей.';


--
-- TOC entry 240 (class 1259 OID 33064)
-- Name: access_role_history_history_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_role_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_role_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 240
-- Name: access_role_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_role_history_history_id_seq OWNED BY access.access_role_history.history_id;


--
-- TOC entry 237 (class 1259 OID 33032)
-- Name: access_role_includes; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_role_includes (
    id bigint NOT NULL,
    client_id text NOT NULL,
    parent_role text NOT NULL,
    child_role text NOT NULL
);


ALTER TABLE access.access_role_includes OWNER TO postgres;

--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE access_role_includes; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_role_includes IS 'Вхождение ролей в роль(иерархия)';


--
-- TOC entry 243 (class 1259 OID 33075)
-- Name: access_role_includes_history; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_role_includes_history (
    history_id bigint NOT NULL,
    client_id text NOT NULL,
    parent_role text NOT NULL,
    child_role text NOT NULL,
    change_type text NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.access_role_includes_history OWNER TO postgres;

--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE access_role_includes_history; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_role_includes_history IS 'История изменения вхождения ролей. Добавили/удалили';


--
-- TOC entry 242 (class 1259 OID 33074)
-- Name: access_role_includes_history_history_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_role_includes_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_role_includes_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 242
-- Name: access_role_includes_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_role_includes_history_history_id_seq OWNED BY access.access_role_includes_history.history_id;


--
-- TOC entry 236 (class 1259 OID 33031)
-- Name: access_role_includes_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_role_includes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_role_includes_id_seq OWNER TO postgres;

--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 236
-- Name: access_role_includes_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_role_includes_id_seq OWNED BY access.access_role_includes.id;


--
-- TOC entry 239 (class 1259 OID 33051)
-- Name: access_role_rights; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_role_rights (
    id bigint NOT NULL,
    client_id text NOT NULL,
    role_code text NOT NULL,
    right_code text NOT NULL
);


ALTER TABLE access.access_role_rights OWNER TO postgres;

--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE access_role_rights; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_role_rights IS 'Вхождение прав в роль';


--
-- TOC entry 245 (class 1259 OID 33085)
-- Name: access_role_rights_history; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_role_rights_history (
    history_id bigint NOT NULL,
    client_id text NOT NULL,
    role_code text NOT NULL,
    right_code text NOT NULL,
    change_type text NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.access_role_rights_history OWNER TO postgres;

--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE access_role_rights_history; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_role_rights_history IS 'История вхождения прав в роль
';


--
-- TOC entry 244 (class 1259 OID 33084)
-- Name: access_role_rights_history_history_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_role_rights_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_role_rights_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 244
-- Name: access_role_rights_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_role_rights_history_history_id_seq OWNED BY access.access_role_rights_history.history_id;


--
-- TOC entry 238 (class 1259 OID 33050)
-- Name: access_role_rights_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_role_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_role_rights_id_seq OWNER TO postgres;

--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 238
-- Name: access_role_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_role_rights_id_seq OWNED BY access.access_role_rights.id;


--
-- TOC entry 235 (class 1259 OID 33022)
-- Name: access_roles; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_roles (
    client_id text NOT NULL,
    role_code text NOT NULL,
    role_name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    retired_at timestamp with time zone
);


ALTER TABLE access.access_roles OWNER TO postgres;

--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE access_roles; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_roles IS 'Список ролей для ролевой модели для каждого клиента';


--
-- TOC entry 233 (class 1259 OID 33005)
-- Name: access_user_roles; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.access_user_roles (
    id bigint NOT NULL,
    client_id text NOT NULL,
    username text NOT NULL,
    role_code text NOT NULL,
    granted_from date NOT NULL,
    granted_to date,
    change_reason text NOT NULL,
    change_request bigint,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.access_user_roles OWNER TO postgres;

--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE access_user_roles; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.access_user_roles IS 'Факты предоставления доступа';


--
-- TOC entry 232 (class 1259 OID 33004)
-- Name: access_user_roles_id_seq; Type: SEQUENCE; Schema: access; Owner: postgres
--

CREATE SEQUENCE access.access_user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE access.access_user_roles_id_seq OWNER TO postgres;

--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 232
-- Name: access_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: access; Owner: postgres
--

ALTER SEQUENCE access.access_user_roles_id_seq OWNED BY access.access_user_roles.id;


--
-- TOC entry 219 (class 1259 OID 24701)
-- Name: clients; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.clients (
    id text NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.clients OWNER TO postgres;

--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE clients; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.clients IS 'Справочник клиентов (Например, кадры, кадры-WEB зарплата и т.д.)';


--
-- TOC entry 217 (class 1259 OID 16458)
-- Name: db_version; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.db_version (
    version text NOT NULL,
    applied_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE access.db_version OWNER TO postgres;

--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE db_version; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.db_version IS 'Версия БД для проверки при запуске службы';


--
-- TOC entry 224 (class 1259 OID 32951)
-- Name: departments; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.departments (
    client_id text NOT NULL,
    department_code text NOT NULL,
    name text NOT NULL
);


ALTER TABLE access.departments OWNER TO postgres;

--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE departments; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.departments IS 'Справочник подразделений';


--
-- TOC entry 222 (class 1259 OID 32930)
-- Name: employees; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.employees (
    client_id text NOT NULL,
    employee_id text NOT NULL,
    username text NOT NULL,
    full_name text NOT NULL,
    position_code text NOT NULL,
    department_code text NOT NULL
);


ALTER TABLE access.employees OWNER TO postgres;

--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE employees; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.employees IS 'Справочник Работников != справочник пользователей';


--
-- TOC entry 223 (class 1259 OID 32944)
-- Name: positions; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.positions (
    client_id text NOT NULL,
    position_code text NOT NULL,
    name text NOT NULL
);


ALTER TABLE access.positions OWNER TO postgres;

--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE positions; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.positions IS 'Справочник должностей';


--
-- TOC entry 225 (class 1259 OID 32958)
-- Name: staff_struct; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.staff_struct (
    client_id text NOT NULL,
    staff_pos integer NOT NULL,
    prd integer NOT NULL,
    pos_depart_code text NOT NULL,
    employee_id text DEFAULT ''::text NOT NULL,
    parent_staff_pos integer
);


ALTER TABLE access.staff_struct OWNER TO postgres;

--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE staff_struct; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.staff_struct IS 'Структура организации для удобного отображения. Историю не храним. Обновляется каждый день. Только текущая.';


--
-- TOC entry 220 (class 1259 OID 24709)
-- Name: user_properties; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.user_properties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id text NOT NULL,
    property_code text NOT NULL,
    value text NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    username text NOT NULL
);


ALTER TABLE access.user_properties OWNER TO postgres;

--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE user_properties; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.user_properties IS 'Свойства работника(пока просто для дополнительного отображения)';


--
-- TOC entry 221 (class 1259 OID 32891)
-- Name: user_property_dictionary; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.user_property_dictionary (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id text NOT NULL,
    property_code text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    default_value text,
    description text
);


ALTER TABLE access.user_property_dictionary OWNER TO postgres;

--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE user_property_dictionary; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.user_property_dictionary IS 'Справочник свойств работника, которые будет отдавать клиент по каждому работнику';


--
-- TOC entry 216 (class 1259 OID 16386)
-- Name: users; Type: TABLE; Schema: access; Owner: postgres
--

CREATE TABLE access.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(100) NOT NULL,
    client_id character varying(50) NOT NULL
);


ALTER TABLE access.users OWNER TO postgres;

--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE users; Type: COMMENT; Schema: access; Owner: postgres
--

COMMENT ON TABLE access.users IS 'Справочник пользователей';


--
-- TOC entry 3375 (class 2604 OID 32994)
-- Name: access_request_actions action_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_actions ALTER COLUMN action_id SET DEFAULT nextval('access.access_request_actions_action_id_seq'::regclass);


--
-- TOC entry 3374 (class 2604 OID 32980)
-- Name: access_request_users request_user_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_users ALTER COLUMN request_user_id SET DEFAULT nextval('access.access_request_users_request_user_id_seq'::regclass);


--
-- TOC entry 3372 (class 2604 OID 32970)
-- Name: access_requests request_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_requests ALTER COLUMN request_id SET DEFAULT nextval('access.access_requests_request_id_seq'::regclass);


--
-- TOC entry 3390 (class 2604 OID 33107)
-- Name: access_rights_history history_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_rights_history ALTER COLUMN history_id SET DEFAULT nextval('access.access_rights_history_history_id_seq'::regclass);


--
-- TOC entry 3382 (class 2604 OID 33068)
-- Name: access_role_history history_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_history ALTER COLUMN history_id SET DEFAULT nextval('access.access_role_history_history_id_seq'::regclass);


--
-- TOC entry 3380 (class 2604 OID 33035)
-- Name: access_role_includes id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes ALTER COLUMN id SET DEFAULT nextval('access.access_role_includes_id_seq'::regclass);


--
-- TOC entry 3384 (class 2604 OID 33078)
-- Name: access_role_includes_history history_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes_history ALTER COLUMN history_id SET DEFAULT nextval('access.access_role_includes_history_history_id_seq'::regclass);


--
-- TOC entry 3381 (class 2604 OID 33054)
-- Name: access_role_rights id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_rights ALTER COLUMN id SET DEFAULT nextval('access.access_role_rights_id_seq'::regclass);


--
-- TOC entry 3386 (class 2604 OID 33088)
-- Name: access_role_rights_history history_id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_rights_history ALTER COLUMN history_id SET DEFAULT nextval('access.access_role_rights_history_history_id_seq'::regclass);


--
-- TOC entry 3376 (class 2604 OID 33008)
-- Name: access_user_roles id; Type: DEFAULT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_user_roles ALTER COLUMN id SET DEFAULT nextval('access.access_user_roles_id_seq'::regclass);


--
-- TOC entry 3612 (class 0 OID 33015)
-- Dependencies: 234
-- Data for Name: access_current_roles; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_current_roles (client_id, username, role_code) FROM stdin;
\.


--
-- TOC entry 3609 (class 0 OID 32991)
-- Dependencies: 231
-- Data for Name: access_request_actions; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_request_actions (action_id, request_id, target_username, role_code, action_type, effective_from, effective_to) FROM stdin;
\.


--
-- TOC entry 3607 (class 0 OID 32977)
-- Dependencies: 229
-- Data for Name: access_request_users; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_request_users (request_user_id, request_id, target_username) FROM stdin;
\.


--
-- TOC entry 3605 (class 0 OID 32967)
-- Dependencies: 227
-- Data for Name: access_requests; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_requests (request_id, client_id, created_by, approved_by, created_at, approved_at, status, comment) FROM stdin;
\.


--
-- TOC entry 3624 (class 0 OID 33094)
-- Dependencies: 246
-- Data for Name: access_rights; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_rights (client_id, right_code, right_name, is_active, created_at, retired_at) FROM stdin;
\.


--
-- TOC entry 3626 (class 0 OID 33104)
-- Dependencies: 248
-- Data for Name: access_rights_history; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_rights_history (history_id, client_id, right_code, change_type, old_value, new_value, changed_at) FROM stdin;
\.


--
-- TOC entry 3619 (class 0 OID 33065)
-- Dependencies: 241
-- Data for Name: access_role_history; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_role_history (history_id, client_id, role_code, change_type, old_value, new_value, changed_at) FROM stdin;
1	kadry	1	create	\N	ПК Персонал	2026-09-10 14:27:44.344076+00
2	kadry	1	rename	ПК Персонал	string	2026-09-11 08:37:24.145087+00
\.


--
-- TOC entry 3615 (class 0 OID 33032)
-- Dependencies: 237
-- Data for Name: access_role_includes; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_role_includes (id, client_id, parent_role, child_role) FROM stdin;
\.


--
-- TOC entry 3621 (class 0 OID 33075)
-- Dependencies: 243
-- Data for Name: access_role_includes_history; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_role_includes_history (history_id, client_id, parent_role, child_role, change_type, changed_at) FROM stdin;
\.


--
-- TOC entry 3617 (class 0 OID 33051)
-- Dependencies: 239
-- Data for Name: access_role_rights; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_role_rights (id, client_id, role_code, right_code) FROM stdin;
\.


--
-- TOC entry 3623 (class 0 OID 33085)
-- Dependencies: 245
-- Data for Name: access_role_rights_history; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_role_rights_history (history_id, client_id, role_code, right_code, change_type, changed_at) FROM stdin;
\.


--
-- TOC entry 3613 (class 0 OID 33022)
-- Dependencies: 235
-- Data for Name: access_roles; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_roles (client_id, role_code, role_name, is_active, created_at, retired_at) FROM stdin;
kadry	1	ПК Персонал	t	2026-09-10 14:27:44.344076+00	\N
\.


--
-- TOC entry 3611 (class 0 OID 33005)
-- Dependencies: 233
-- Data for Name: access_user_roles; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.access_user_roles (id, client_id, username, role_code, granted_from, granted_to, change_reason, change_request, changed_at) FROM stdin;
\.


--
-- TOC entry 3597 (class 0 OID 24701)
-- Dependencies: 219
-- Data for Name: clients; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.clients (id, name, created_at) FROM stdin;
kadry	ПК Персонал	2026-09-07 14:33:12.288774
\.


--
-- TOC entry 3596 (class 0 OID 16458)
-- Dependencies: 217
-- Data for Name: db_version; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.db_version (version, applied_at) FROM stdin;
001	2026-08-24 12:34:26.100799
002	2026-08-24 12:34:32.848809
\.


--
-- TOC entry 3602 (class 0 OID 32951)
-- Dependencies: 224
-- Data for Name: departments; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.departments (client_id, department_code, name) FROM stdin;
\.


--
-- TOC entry 3600 (class 0 OID 32930)
-- Dependencies: 222
-- Data for Name: employees; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.employees (client_id, employee_id, username, full_name, position_code, department_code) FROM stdin;
\.


--
-- TOC entry 3601 (class 0 OID 32944)
-- Dependencies: 223
-- Data for Name: positions; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.positions (client_id, position_code, name) FROM stdin;
\.


--
-- TOC entry 3603 (class 0 OID 32958)
-- Dependencies: 225
-- Data for Name: staff_struct; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.staff_struct (client_id, staff_pos, prd, pos_depart_code, employee_id, parent_staff_pos) FROM stdin;
\.


--
-- TOC entry 3598 (class 0 OID 24709)
-- Dependencies: 220
-- Data for Name: user_properties; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.user_properties (id, client_id, property_code, value, updated_at, username) FROM stdin;
d84fd617-6d39-4402-8712-703d5b426e92	kadry	full_name	"Ivanov ФИО"	2026-09-09 09:24:12.825802	ivanov
3bc8027a-cacb-4394-8885-d305757c7234	kadry	email	"ivanov@example.com"	2026-09-09 09:24:12.825802	ivanov
743d8b40-aa44-488b-a340-6173e52ccee2	kadry	full_name	"Petrov ФИО"	2026-09-09 09:24:12.825802	petrov
770bb50e-e916-4bb8-968d-b3f4277d1ac3	kadry	email	"petrov@example.com"	2026-09-09 09:24:12.825802	petrov
\.


--
-- TOC entry 3599 (class 0 OID 32891)
-- Dependencies: 221
-- Data for Name: user_property_dictionary; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.user_property_dictionary (id, client_id, property_code, title, type, is_required, default_value, description) FROM stdin;
fa4e0fb5-e134-495b-9d77-ec897174d009	kadry	full_name	ФИО	string	t		Полное имя пользователя
8c7b2e88-5d55-48c1-a698-8f0db6525089	kadry	email	Email	string	f		Электронная почта
\.


--
-- TOC entry 3595 (class 0 OID 16386)
-- Dependencies: 216
-- Data for Name: users; Type: TABLE DATA; Schema: access; Owner: postgres
--

COPY access.users (id, username, client_id) FROM stdin;
3901d06c-7a28-4cd8-bab4-76ce79a520ae	ivanov	kadry
1dd854b5-dd71-4c6a-be34-a63e6966b016	petrov	kadry
\.


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 230
-- Name: access_request_actions_action_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_request_actions_action_id_seq', 1, false);


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 228
-- Name: access_request_users_request_user_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_request_users_request_user_id_seq', 1, false);


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 226
-- Name: access_requests_request_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_requests_request_id_seq', 1, false);


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 247
-- Name: access_rights_history_history_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_rights_history_history_id_seq', 1, false);


--
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 240
-- Name: access_role_history_history_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_role_history_history_id_seq', 2, true);


--
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 242
-- Name: access_role_includes_history_history_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_role_includes_history_history_id_seq', 1, false);


--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 236
-- Name: access_role_includes_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_role_includes_id_seq', 1, false);


--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 244
-- Name: access_role_rights_history_history_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_role_rights_history_history_id_seq', 1, false);


--
-- TOC entry 3672 (class 0 OID 0)
-- Dependencies: 238
-- Name: access_role_rights_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_role_rights_id_seq', 1, false);


--
-- TOC entry 3673 (class 0 OID 0)
-- Dependencies: 232
-- Name: access_user_roles_id_seq; Type: SEQUENCE SET; Schema: access; Owner: postgres
--

SELECT pg_catalog.setval('access.access_user_roles_id_seq', 1, false);


--
-- TOC entry 3427 (class 2606 OID 33021)
-- Name: access_current_roles access_current_roles_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_current_roles
    ADD CONSTRAINT access_current_roles_pkey PRIMARY KEY (client_id, username, role_code);


--
-- TOC entry 3423 (class 2606 OID 32998)
-- Name: access_request_actions access_request_actions_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_actions
    ADD CONSTRAINT access_request_actions_pkey PRIMARY KEY (action_id);


--
-- TOC entry 3421 (class 2606 OID 32984)
-- Name: access_request_users access_request_users_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_users
    ADD CONSTRAINT access_request_users_pkey PRIMARY KEY (request_user_id);


--
-- TOC entry 3419 (class 2606 OID 32975)
-- Name: access_requests access_requests_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_requests
    ADD CONSTRAINT access_requests_pkey PRIMARY KEY (request_id);


--
-- TOC entry 3443 (class 2606 OID 33112)
-- Name: access_rights_history access_rights_history_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_rights_history
    ADD CONSTRAINT access_rights_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 3441 (class 2606 OID 33102)
-- Name: access_rights access_rights_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_rights
    ADD CONSTRAINT access_rights_pkey PRIMARY KEY (client_id, right_code);


--
-- TOC entry 3435 (class 2606 OID 33073)
-- Name: access_role_history access_role_history_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_history
    ADD CONSTRAINT access_role_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 3437 (class 2606 OID 33083)
-- Name: access_role_includes_history access_role_includes_history_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes_history
    ADD CONSTRAINT access_role_includes_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 3431 (class 2606 OID 33039)
-- Name: access_role_includes access_role_includes_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes
    ADD CONSTRAINT access_role_includes_pkey PRIMARY KEY (id);


--
-- TOC entry 3439 (class 2606 OID 33093)
-- Name: access_role_rights_history access_role_rights_history_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_rights_history
    ADD CONSTRAINT access_role_rights_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 3433 (class 2606 OID 33058)
-- Name: access_role_rights access_role_rights_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_rights
    ADD CONSTRAINT access_role_rights_pkey PRIMARY KEY (id);


--
-- TOC entry 3429 (class 2606 OID 33030)
-- Name: access_roles access_roles_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_roles
    ADD CONSTRAINT access_roles_pkey PRIMARY KEY (client_id, role_code);


--
-- TOC entry 3425 (class 2606 OID 33013)
-- Name: access_user_roles access_user_roles_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_user_roles
    ADD CONSTRAINT access_user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 3400 (class 2606 OID 24708)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- TOC entry 3398 (class 2606 OID 16465)
-- Name: db_version db_version_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.db_version
    ADD CONSTRAINT db_version_pkey PRIMARY KEY (version);


--
-- TOC entry 3415 (class 2606 OID 32957)
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (client_id, department_code);


--
-- TOC entry 3409 (class 2606 OID 32936)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (client_id, employee_id);


--
-- TOC entry 3411 (class 2606 OID 32938)
-- Name: employees employees_username_unique; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.employees
    ADD CONSTRAINT employees_username_unique UNIQUE (client_id, username);


--
-- TOC entry 3413 (class 2606 OID 32950)
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (client_id, position_code);


--
-- TOC entry 3417 (class 2606 OID 32965)
-- Name: staff_struct staff_struct_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.staff_struct
    ADD CONSTRAINT staff_struct_pkey PRIMARY KEY (client_id, staff_pos);


--
-- TOC entry 3402 (class 2606 OID 32923)
-- Name: user_properties user_properties_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.user_properties
    ADD CONSTRAINT user_properties_pkey PRIMARY KEY (client_id, username, property_code);


--
-- TOC entry 3405 (class 2606 OID 32899)
-- Name: user_property_dictionary user_property_dictionary_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.user_property_dictionary
    ADD CONSTRAINT user_property_dictionary_pkey PRIMARY KEY (id);


--
-- TOC entry 3407 (class 2606 OID 32901)
-- Name: user_property_dictionary user_property_dictionary_unique; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.user_property_dictionary
    ADD CONSTRAINT user_property_dictionary_unique UNIQUE (client_id, property_code);


--
-- TOC entry 3394 (class 2606 OID 32921)
-- Name: users users_client_username; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.users
    ADD CONSTRAINT users_client_username UNIQUE (client_id, username);


--
-- TOC entry 3396 (class 2606 OID 16392)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3392 (class 1259 OID 24700)
-- Name: idx_client_user_uniq; Type: INDEX; Schema: access; Owner: postgres
--

CREATE UNIQUE INDEX idx_client_user_uniq ON access.users USING btree (client_id, username) WITH (deduplicate_items='true');


--
-- TOC entry 3403 (class 1259 OID 32907)
-- Name: idx_user_property_dictionary_clientid_propertycode; Type: INDEX; Schema: access; Owner: postgres
--

CREATE UNIQUE INDEX idx_user_property_dictionary_clientid_propertycode ON access.user_property_dictionary USING btree (client_id, property_code) WITH (deduplicate_items='true');


--
-- TOC entry 3449 (class 2606 OID 33045)
-- Name: access_role_includes access_role_includes_client_id_child_role_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes
    ADD CONSTRAINT access_role_includes_client_id_child_role_fkey FOREIGN KEY (client_id, child_role) REFERENCES access.access_roles(client_id, role_code);


--
-- TOC entry 3450 (class 2606 OID 33040)
-- Name: access_role_includes access_role_includes_client_id_parent_role_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_includes
    ADD CONSTRAINT access_role_includes_client_id_parent_role_fkey FOREIGN KEY (client_id, parent_role) REFERENCES access.access_roles(client_id, role_code);


--
-- TOC entry 3451 (class 2606 OID 33059)
-- Name: access_role_rights access_role_rights_client_id_role_code_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_role_rights
    ADD CONSTRAINT access_role_rights_client_id_role_code_fkey FOREIGN KEY (client_id, role_code) REFERENCES access.access_roles(client_id, role_code);


--
-- TOC entry 3446 (class 2606 OID 32939)
-- Name: employees employees_user_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.employees
    ADD CONSTRAINT employees_user_fkey FOREIGN KEY (client_id, username) REFERENCES access.users(client_id, username) ON DELETE RESTRICT;


--
-- TOC entry 3448 (class 2606 OID 32999)
-- Name: access_request_actions fk_request_actions; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_actions
    ADD CONSTRAINT fk_request_actions FOREIGN KEY (request_id) REFERENCES access.access_requests(request_id) ON DELETE RESTRICT;


--
-- TOC entry 3447 (class 2606 OID 32985)
-- Name: access_request_users fk_request_users; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.access_request_users
    ADD CONSTRAINT fk_request_users FOREIGN KEY (request_id) REFERENCES access.access_requests(request_id) ON DELETE RESTRICT;


--
-- TOC entry 3444 (class 2606 OID 32924)
-- Name: user_properties user_properties_user_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.user_properties
    ADD CONSTRAINT user_properties_user_fkey FOREIGN KEY (client_id, username) REFERENCES access.users(client_id, username) ON DELETE CASCADE;


--
-- TOC entry 3445 (class 2606 OID 32902)
-- Name: user_property_dictionary user_property_dictionary_client_id_fkey; Type: FK CONSTRAINT; Schema: access; Owner: postgres
--

ALTER TABLE ONLY access.user_property_dictionary
    ADD CONSTRAINT user_property_dictionary_client_id_fkey FOREIGN KEY (client_id) REFERENCES access.clients(id) ON DELETE CASCADE;


-- Completed on 2026-09-11 12:43:23

--
-- PostgreSQL database dump complete
--

\unrestrict NtZV7EvC8RDKCF0zUjBjBNanYmSPBdpL5h1GPpF9WKaPSqAVNeywsGtVBkh2z6F


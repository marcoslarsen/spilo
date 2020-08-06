SET search_path TO public;

-- Table dfm_configuration_meta
CREATE SEQUENCE IF NOT EXISTS dfm_configuration_meta_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_configuration_meta (
  id                      BIGINT        NOT NULL,
  PRIMARY KEY (id)
);

-- Table dfm_parameter_group
CREATE SEQUENCE IF NOT EXISTS dfm_parameter_group_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_parameter_group (
  id                      BIGINT        NOT NULL,
  name                    VARCHAR(2048) NOT NULL,
  configuration_id        BIGINT,
  PRIMARY KEY (id),
  FOREIGN KEY (configuration_id) REFERENCES dfm_configuration_meta (id)
);
CREATE INDEX IF NOT EXISTS dfm_parameter_group_configuration_id_idx ON dfm_parameter_group(configuration_id);

-- Table dfm_parameter_meta
CREATE SEQUENCE IF NOT EXISTS dfm_parameter_meta_seq INCREMENT 20 START 1;
CREATE TABLE IF NOT EXISTS dfm_parameter_meta (
  id                      BIGINT        NOT NULL,
  parameter_key           VARCHAR(250)  NOT NULL,
  parameter_name          VARCHAR(250)  NOT NULL,
  default_value           VARCHAR(2048),
  description             VARCHAR(1024),
  parameter_type          VARCHAR(64),
  mandatory               BOOLEAN,
  type_options            VARCHAR(1024),
  group_id                BIGINT        NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (group_id) REFERENCES dfm_parameter_group (id)
);
CREATE INDEX IF NOT EXISTS dfm_parameter_meta_group_id_idx ON dfm_parameter_meta(group_id);

-- Table dfm_dataflow
CREATE SEQUENCE IF NOT EXISTS dfm_dataflow_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_dataflow
(
  id                      BIGINT        NOT NULL,
  name                    VARCHAR(2048) NOT NULL,
  description             VARCHAR(2048),
  entry_point             VARCHAR(2048),
  data_flow_type          VARCHAR(64)   NOT NULL,
  source                  BYTEA,
  configuration_id   BIGINT,
  PRIMARY KEY (id),
  FOREIGN KEY (configuration_id) REFERENCES dfm_configuration_meta (id)
);
CREATE INDEX IF NOT EXISTS dfm_dataflow_configuration_id_idx ON dfm_dataflow(configuration_id);
CREATE INDEX IF NOT EXISTS dfm_dataflow_name_uc_idx ON dfm_dataflow (UPPER(name));

-- Table dfm_schedule
CREATE SEQUENCE IF NOT EXISTS dfm_schedule_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_schedule
(
  id                  BIGINT       NOT NULL,
  recurrence_type     VARCHAR(64)  NOT NULL,
  state               VARCHAR(64)  NOT NULL,
  username            VARCHAR(250) NOT NULL,
  data_flow_id        BIGINT       NOT NULL,
  external_id         VARCHAR(128) NOT NULL,
  end_by_type         VARCHAR(64),
  start_time          VARCHAR(32),
  end_time            VARCHAR(32),
  timezone            VARCHAR(64),
  next_execution_time TIMESTAMP,
  every               INTEGER,
  cron                VARCHAR(64),
  on_type             VARCHAR(64),
  month_day           INTEGER,
  month_type          VARCHAR(64),
  edited_schedule_id  BIGINT,
  PRIMARY KEY (id),
  UNIQUE (external_id),
  FOREIGN KEY (data_flow_id) REFERENCES dfm_dataflow (id),
  FOREIGN KEY (edited_schedule_id) REFERENCES dfm_schedule (id)
);
CREATE INDEX IF NOT EXISTS dfm_schedules_df_id_idx ON dfm_schedule (data_flow_id);
CREATE INDEX IF NOT EXISTS dfm_schedules_state_id_idx ON dfm_schedule (state);
CREATE INDEX IF NOT EXISTS dfm_schedules_external_id_idx ON dfm_schedule (external_id);
CREATE INDEX IF NOT EXISTS dfm_schedules_df_state_id_idx ON dfm_schedule (data_flow_id, state);

-- Table dfm_execution
CREATE SEQUENCE IF NOT EXISTS dfm_execution_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_execution
(
  id             BIGINT        NOT NULL,
  data_flow_id   BIGINT        NOT NULL,
  data_flow_name VARCHAR(2048) NOT NULL,
  provider_id    VARCHAR(36),
  start_time     TIMESTAMP,
  end_time       TIMESTAMP,
  state          VARCHAR(64)   NOT NULL,
  username       VARCHAR(250)  NOT NULL,
  external_id    VARCHAR(512),
  schedule_id    BIGINT,
  PRIMARY KEY (id),
  FOREIGN KEY (data_flow_id) REFERENCES dfm_dataflow (id),
  FOREIGN KEY (schedule_id) REFERENCES dfm_schedule (id)
);
CREATE INDEX IF NOT EXISTS dfm_execs_df_id_idx ON dfm_execution (data_flow_id);
CREATE INDEX IF NOT EXISTS dfm_execs_df_name_idx ON dfm_execution (data_flow_name);
CREATE INDEX IF NOT EXISTS dfm_execs_df_name_uc_idx ON dfm_execution (UPPER(data_flow_name));
CREATE INDEX IF NOT EXISTS dfm_execs_st_idx ON dfm_execution (state);
CREATE INDEX IF NOT EXISTS dfm_execs_str_time_idx ON dfm_execution (start_time);
CREATE INDEX IF NOT EXISTS dfm_execs_user_idx ON dfm_execution (username);
CREATE INDEX IF NOT EXISTS dfm_execs_user_uc_idx ON dfm_execution (UPPER(username));
CREATE INDEX IF NOT EXISTS dfm_execs_schedule_id_idx ON dfm_execution (schedule_id);

-- Table dfm_execution_parameter
CREATE SEQUENCE IF NOT EXISTS dfm_execution_parameter_seq INCREMENT 20 START 1;
CREATE TABLE IF NOT EXISTS dfm_execution_parameter
(
  id              BIGINT        NOT NULL,
  execution_id    BIGINT        NOT NULL,
  parameter_key   VARCHAR(250)  NOT NULL,
  parameter_value VARCHAR(2048) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (execution_id) REFERENCES dfm_execution (id),
  UNIQUE (execution_id, parameter_key)
);
CREATE INDEX IF NOT EXISTS dfm_exec_params_exec_id_idx ON dfm_execution_parameter (execution_id);

-- Table dfm_schedule_parameter
CREATE SEQUENCE IF NOT EXISTS dfm_schedule_parameter_seq INCREMENT 20 START 1;
CREATE TABLE IF NOT EXISTS dfm_schedule_parameter
(
  id              BIGINT        NOT NULL,
  schedule_id     BIGINT        NOT NULL,
  parameter_key   VARCHAR(250)  NOT NULL,
  parameter_value VARCHAR(2048) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (schedule_id) REFERENCES dfm_schedule (id),
  UNIQUE (schedule_id, parameter_key)
);
CREATE INDEX IF NOT EXISTS dfm_sched_params_exec_id_idx ON dfm_schedule_parameter (schedule_id);

-- Table dfm_schedule_weekday
CREATE SEQUENCE IF NOT EXISTS dfm_schedule_weekday_seq INCREMENT 10 START 1;
CREATE TABLE IF NOT EXISTS dfm_schedule_weekday
(
  id          BIGINT      NOT NULL,
  schedule_id BIGINT      NOT NULL,
  week_day    VARCHAR(64) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (schedule_id) REFERENCES dfm_schedule (id),
  UNIQUE (schedule_id, week_day)
);
CREATE INDEX IF NOT EXISTS dfm_sched_wd_schd_id_idx ON dfm_schedule_weekday (schedule_id);


-- Table dfm_execution_log
CREATE SEQUENCE IF NOT EXISTS dfm_execution_log_seq INCREMENT 20 START 1;
CREATE TABLE IF NOT EXISTS dfm_execution_log
(
  id           BIGINT      NOT NULL,
  execution_id BIGINT      NOT NULL,
  log_level    VARCHAR(64) NOT NULL,
  log_time     TIMESTAMP   NOT NULL,
  message      TEXT        NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (execution_id) REFERENCES dfm_execution (id)
);
CREATE INDEX IF NOT EXISTS dfm_exec_log_exec_id_idx ON dfm_execution_log (execution_id);
CREATE INDEX IF NOT EXISTS dfm_ex_log_ex_time_idx ON dfm_execution_log (execution_id, log_time);

-- Table dfm_execution_status_change
CREATE SEQUENCE IF NOT EXISTS dfm_execution_status_change_seq INCREMENT 20 START 1;
CREATE TABLE IF NOT EXISTS dfm_execution_status_change
(
  id           BIGINT      NOT NULL,
  execution_id BIGINT      NOT NULL,
  state        VARCHAR(64) NOT NULL,
  state_time   TIMESTAMP   NOT NULL,
  type         VARCHAR(64) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (execution_id) REFERENCES dfm_execution (id)
);
CREATE INDEX IF NOT EXISTS dfm_exec_state_exec_id_idx ON dfm_execution_status_change (execution_id);
CREATE INDEX IF NOT EXISTS dfm_ex_state_time_idx ON dfm_execution_status_change (execution_id, state_time);











-- Table dfm_revision_info
CREATE SEQUENCE IF NOT EXISTS dfm_revision_info_seq START 1 INCREMENT 10;
CREATE TABLE IF NOT EXISTS dfm_revision_info
(
  id        INTEGER NOT NULL,
  TIMESTAMP BIGINT  NOT NULL,
  username  VARCHAR(250),
  PRIMARY KEY (id)
);

-- Table dfm_dataflow_aud
CREATE TABLE IF NOT EXISTS dfm_dataflow_aud
(
  id                      BIGINT        NOT NULL,
  rev                     INTEGER       NOT NULL,
  revtype                 SMALLINT,
  revend                  INTEGER,
  name                    VARCHAR(2048),
  description             VARCHAR(2048),
  entry_point             VARCHAR(2048),
  data_flow_type          VARCHAR(64),
  source                  BYTEA,
  configuration_id        BIGINT,
  PRIMARY KEY (id, rev),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_configuration_meta_aud
CREATE TABLE IF NOT EXISTS dfm_configuration_meta_aud
(
  id             BIGINT  NOT NULL,
  REV            INTEGER NOT NULL,
  REVTYPE        SMALLINT,
  REVEND         INTEGER,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_parameter_group_aud
CREATE TABLE IF NOT EXISTS dfm_parameter_group_aud (
  id                BIGINT        NOT NULL,
  REV               INTEGER NOT NULL,
  REVTYPE           SMALLINT,
  REVEND            INTEGER,
  name              VARCHAR(2048),
  configuration_id  BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_parameter_meta
CREATE TABLE IF NOT EXISTS dfm_parameter_meta_aud (
  id             BIGINT        NOT NULL,
  REV            INTEGER NOT NULL,
  REVTYPE        SMALLINT,
  REVEND         INTEGER,
  parameter_key           VARCHAR(250),
  parameter_name          VARCHAR(250),
  default_value           VARCHAR(2048),
  description             VARCHAR(1024),
  parameter_type          VARCHAR(64),
  mandatory               BOOLEAN,
  type_options            VARCHAR(1024),
  group_id                BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_execution_aud
create table IF NOT EXISTS dfm_execution_aud
(
  id             BIGINT  NOT NULL,
  REV            INTEGER NOT NULL,
  REVTYPE        SMALLINT,
  REVEND         INTEGER,
  data_flow_name VARCHAR(2048),
  end_time       TIMESTAMP,
  provider_id    VARCHAR(36),
  start_time     TIMESTAMP,
  state          VARCHAR(64),
  username       VARCHAR(250),
  external_id    VARCHAR(512),
  data_flow_id   BIGINT,
  schedule_id    BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_execution_log_aud
create table IF NOT EXISTS dfm_execution_log_aud
(
  id           BIGINT  NOT NULL,
  REV          INTEGER NOT NULL,
  REVTYPE      SMALLINT,
  REVEND       INTEGER,
  log_level    VARCHAR(64),
  log_time     TIMESTAMP,
  message      TEXT,
  execution_id BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_execution_parameter_aud
create table IF NOT EXISTS dfm_execution_parameter_aud
(
  id              BIGINT  NOT NULL,
  REV             INTEGER NOT NULL,
  REVTYPE         SMALLINT,
  REVEND          INTEGER,
  parameter_key   VARCHAR(250),
  parameter_value VARCHAR(2048),
  execution_id    BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_execution_status_change_aud
create table IF NOT EXISTS dfm_execution_status_change_aud
(
  id           BIGINT  NOT NULL,
  REV          INTEGER NOT NULL,
  REVTYPE      SMALLINT,
  REVEND       INTEGER,
  execution_id BIGINT,
  state        VARCHAR(64),
  state_time   TIMESTAMP,
  type         VARCHAR(64),
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_schedule_aud
create table IF NOT EXISTS dfm_schedule_aud
(
  id                  BIGINT  NOT NULL,
  REV                 INTEGER NOT NULL,
  REVTYPE             SMALLINT,
  REVEND              INTEGER,
  cron                VARCHAR(64),
  edited_schedule_id  BIGINT,
  end_by_type         VARCHAR(64),
  end_time            VARCHAR(32),
  every               INTEGER,
  external_id         VARCHAR(128),
  month_type          VARCHAR(64),
  month_day           INTEGER,
  next_execution_time TIMESTAMP,
  on_type             VARCHAR(64),
  recurrence_type     VARCHAR(64),
  start_time          VARCHAR(32),
  state               VARCHAR(64),
  timezone            VARCHAR(64),
  username            VARCHAR(250),
  data_flow_id        BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_schedule_parameter_aud
create table IF NOT EXISTS dfm_schedule_parameter_aud
(
  id              BIGINT  NOT NULL,
  REV             INTEGER NOT NULL,
  REVTYPE         SMALLINT,
  REVEND          INTEGER,
  parameter_key   VARCHAR(250),
  parameter_value VARCHAR(2048),
  schedule_id     BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);

-- Table dfm_schedule_weekday_aud
create table IF NOT EXISTS dfm_schedule_weekday_aud
(
  id          BIGINT  NOT NULL,
  REV         INTEGER NOT NULL,
  REVTYPE     SMALLINT,
  REVEND      INTEGER,
  week_day    VARCHAR(64),
  schedule_id BIGINT,
  PRIMARY KEY (id, REV),
  FOREIGN KEY (revend) REFERENCES dfm_revision_info (id),
  FOREIGN KEY (rev) REFERENCES dfm_revision_info (id)
);
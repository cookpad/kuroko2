class CreateExecutions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE executions (
        id      INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        uuid    VARCHAR(36)      NOT NULL,

        job_definition_id      INTEGER UNSIGNED,
        job_definition_version INTEGER UNSIGNED,
        job_instance_id        INTEGER UNSIGNED,

        token_id           INTEGER UNSIGNED,

        queue         VARCHAR(180) NOT NULL DEFAULT '@default',

        shell         VARCHAR(180) NOT NULL,
        context       TEXT         NOT NULL,

        pid           INTEGER UNSIGNED,
        output        LONGTEXT,
        exit_status   TINYINT,
        term_signal   TINYINT,

        started_at   DATETIME,
        finished_at  DATETIME,
        mailed_at    DATETIME,

        created_at   DATETIME,
        updated_at   DATETIME,

        PRIMARY KEY (id),
        UNIQUE(job_definition_id, token_id),
        KEY(started_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS executions;
    SQL
  end
end

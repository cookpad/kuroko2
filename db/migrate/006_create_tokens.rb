class CreateTokens < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE tokens (
        id      INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        uuid    VARCHAR(36)     NOT NULL,

        job_definition_id      INTEGER UNSIGNED,
        job_definition_version INTEGER UNSIGNED,
        job_instance_id        INTEGER UNSIGNED,

        parent_id            INTEGER,

        script  TEXT         NOT NULL,

        path    VARCHAR(180) NOT NULL DEFAULT '/',

        status  INTEGER      NOT NULL DEFAULT 0,
        message TEXT         NOT NULL,

        context TEXT         NOT NULL,

        created_at DATETIME,
        updated_at DATETIME,

        PRIMARY KEY (id),
        KEY(parent_id),
        KEY(status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS tokens;
    SQL
  end
end

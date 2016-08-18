class CreateJobDefinitions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE job_definitions (
        id      INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        version INTEGER UNSIGNED NOT NULL DEFAULT 0,

        name        VARCHAR(180) NOT NULL,
        description TEXT         NOT NULL,
        script      TEXT         NOT NULL,

        suspended     TINYINT(1) NOT NULL DEFAULT 0,
        prevent_multi TINYINT(1) NOT NULL DEFAULT 1,

        hipchat_room            VARCHAR(180) NOT NULL DEFAULT '',
        hipchat_notify_finished TINYINT(1)   NOT NULL DEFAULT 1,

        created_at DATETIME,
        updated_at DATETIME,

        PRIMARY KEY (id),
        KEY(name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS job_definitions;
    SQL
  end
end

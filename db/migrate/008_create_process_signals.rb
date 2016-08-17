class CreateProcessSignals < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE process_signals (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        pid          INTEGER UNSIGNED NOT NULL,
        number       TINYINT UNSIGNED NOT NULL DEFAULT 15, -- SIGTERM

        started_at   DATETIME,

        created_at   DATETIME,
        updated_at   DATETIME,

        message      TEXT,

        PRIMARY KEY (id),
        KEY(started_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS process_signals;
    SQL
  end
end

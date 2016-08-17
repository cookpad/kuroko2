class CreateLogs < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE logs (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        job_instance_id INTEGER UNSIGNED,

        level   VARCHAR(10),
        message LONGTEXT,

        created_at DATETIME,
        updated_at DATETIME,

        PRIMARY KEY (id),
        KEY(job_instance_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS logs;
    SQL
  end
end

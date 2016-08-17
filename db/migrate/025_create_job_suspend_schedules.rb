class CreateJobSuspendSchedules < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE job_suspend_schedules (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        job_definition_id  INTEGER UNSIGNED,

        cron VARCHAR(180),

        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,

        PRIMARY KEY (id),
        UNIQUE (job_definition_id, cron)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS job_suspend_schedules;
    SQL
  end
end

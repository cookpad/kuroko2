class CreateJobInstances < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE job_instances (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        job_definition_id      INTEGER UNSIGNED,
        job_definition_version INTEGER UNSIGNED,

        script TEXT,

        finished_at DATETIME,
        canceled_at DATETIME,
        error_at    DATETIME,

        created_at DATETIME,
        updated_at DATETIME,

        PRIMARY KEY (id),
        KEY(job_definition_id),
        KEY(finished_at, canceled_at, job_definition_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS job_instances;
    SQL
  end
end

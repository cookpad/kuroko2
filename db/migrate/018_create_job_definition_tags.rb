class CreateJobDefinitionTags < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE job_definition_tags (
        id                INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        job_definition_id INTEGER UNSIGNED NOT NULL,
        tag_id            INTEGER UNSIGNED NOT NULL,
        created_at        DATETIME NOT NULL,
        updated_at        DATETIME NOT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY (job_definition_id, tag_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS job_definition_tags;
    SQL
  end
end

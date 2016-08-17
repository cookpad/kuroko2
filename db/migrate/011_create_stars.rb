class CreateStars < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE stars (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        user_id           INTEGER UNSIGNED NOT NULL,
        job_definition_id INTEGER UNSIGNED NOT NULL,

        created_at   DATETIME,
        updated_at   DATETIME,

        PRIMARY KEY(id),
        UNIQUE(user_id, job_definition_id)
      )
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS stars;
    SQL
  end
end

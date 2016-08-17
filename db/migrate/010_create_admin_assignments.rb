class CreateAdminAssignments < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE admin_assignments (
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
      DROP TABLE IF EXISTS admin_assignments;
    SQL
  end
end

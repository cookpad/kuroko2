class AlterPreventMultiOnErrorToJobDefinition < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE job_definitions MODIFY prevent_multi INTEGER UNSIGNED NOT NULL DEFAULT 1
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE job_definitions MODIFY prevent_multi TINYINT(1) NOT NULL NULL DEFAULT 1
    SQL
  end
end

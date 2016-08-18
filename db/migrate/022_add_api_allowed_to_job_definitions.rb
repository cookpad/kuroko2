class AddApiAllowedToJobDefinitions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE job_definitions ADD COLUMN api_allowed TINYINT(1) NOT NULL DEFAULT 0 AFTER hipchat_additional_text
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE job_definitions DROP COLUMN api_allowed
    SQL
  end
end

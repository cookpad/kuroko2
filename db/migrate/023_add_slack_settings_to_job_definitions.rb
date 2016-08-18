class AddSlackSettingsToJobDefinitions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE job_definitions ADD COLUMN slack_channel VARCHAR(180) NOT NULL DEFAULT '' AFTER hipchat_additional_text
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE job_definitions DROP COLUMN slack_channel
    SQL
  end
end

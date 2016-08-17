class AddHipchatAdditionalTextToJobDefinitions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE job_definitions ADD COLUMN hipchat_additional_text VARCHAR(180) AFTER hipchat_notify_finished
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE job_definitions DROP COLUMN hipchat_additional_text
    SQL
  end
end

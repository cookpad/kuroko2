class AddNotifyCancellationToJobDefinitions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE job_definitions ADD COLUMN notify_cancellation TINYINT(1) NOT NULL DEFAULT 1 AFTER prevent_multi
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE job_definitions DROP COLUMN notify_cancellation
    SQL
  end
end

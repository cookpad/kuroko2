class ChangeColumnToExecutions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE executions CHANGE COLUMN exit_status exit_status tinyint(4) unsigned DEFAULT NULL;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE executions CHANGE COLUMN exit_status exit_status tinyint(4) DEFAULT NULL;
    SQL
  end
end

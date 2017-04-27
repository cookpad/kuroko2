class ChangeExitStatusToUnsignedTinyint < ActiveRecord::Migration
  def up
    change_column :executions, :exit_status, 'tinyint(4) unsigned'
  end

  def down
    change_column :executions, :exit_status, :integer, limit: 1
  end
end

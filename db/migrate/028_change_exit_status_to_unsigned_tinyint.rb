class ChangeExitStatusToUnsignedTinyint < ActiveRecord::Migration
  def up
    change_column :executions, :exit_status, :integer, limit: 2
  end

  def down
    change_column :executions, :exit_status, :integer, limit: 1
  end
end

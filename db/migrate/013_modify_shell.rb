class ModifyShell < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE executions MODIFY shell TEXT NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE executions MODIFY shell VARCHAR(180) NOT NULL
    SQL
  end
end

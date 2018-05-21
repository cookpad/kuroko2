class AlterKeyAndIndexToBigint < ActiveRecord::Migration[5.0]
  def up
    change_column :job_definitions, :id, :bigint, auto_increment: true
    change_column :admin_assignments, :job_definition_id, :bigint
    change_column :execution_histories, :job_definition_id, :bigint
    change_column :executions, :job_definition_id, :bigint
    change_column :job_definition_tags, :job_definition_id, :bigint
    change_column :job_instances, :job_definition_id, :bigint
    change_column :job_schedules, :job_definition_id, :bigint
    change_column :job_suspend_schedules, :job_definition_id, :bigint
    change_column :memory_expectancies, :job_definition_id, :bigint
    change_column :stars, :job_definition_id, :bigint
    change_column :tokens, :job_definition_id, :bigint

    change_column :users, :id, :bigint, auto_increment: true
    change_column :admin_assignments, :user_id, :bigint
    change_column :stars, :user_id, :bigint
  end

  def down
    change_column :job_definitions, :id, :int, auto_increment: true
    change_column :admin_assignments, :job_definition_id, :int
    change_column :execution_histories, :job_definition_id, :int
    change_column :executions, :job_definition_id, :int
    change_column :job_definition_tags, :job_definition_id, :int
    change_column :job_instances, :job_definition_id, :int
    change_column :job_schedules, :job_definition_id, :int
    change_column :job_suspend_schedules, :job_definition_id, :int
    change_column :memory_expectancies, :job_definition_id, :int
    change_column :stars, :job_definition_id, :int
    change_column :tokens, :job_definition_id, :int

    change_column :users, :id, :int, auto_increment: true
    change_column :admin_assignments, :user_id, :int
    change_column :stars, :user_id, :int
  end
end

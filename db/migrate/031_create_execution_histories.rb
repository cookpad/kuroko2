class CreateExecutionHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :execution_histories do |t|
      t.string :hostname, limit: 180
      t.integer :worker_id, limit: 1
      t.string :queue, limit: 180, default: "@default", null: false
      t.integer :job_definition_id, null: false
      t.integer :job_instance_id, null: false
      t.text :shell, null: false
      t.datetime :started_at, null: false
      t.datetime :finished_at, null: false
    end

    add_column :executions, :hostname, :string, limit: 180
    add_column :executions, :worker_id, :integer, limit: 1

    add_index :execution_histories, [:worker_id, :started_at], using: :btree
  end
end

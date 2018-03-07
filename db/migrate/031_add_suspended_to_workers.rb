class AddSuspendedToWorkers < ActiveRecord::Migration[5.0]
  def change
    add_column :workers, :suspendable, :boolean, default: false, null: false, after: :execution_id
    add_column :workers, :suspended, :boolean, default: false, null: false, after: :suspendable
  end
end

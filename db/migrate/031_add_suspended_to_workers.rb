class AddSuspendedToWorkers < ActiveRecord::Migration[5.1]
  def change
    add_column :workers, :suspended, :boolean, default: false, null: false, after: :execution_id
  end
end

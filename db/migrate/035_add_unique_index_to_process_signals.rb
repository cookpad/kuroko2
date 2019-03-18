class AddUniqueIndexToProcessSignals < ActiveRecord::Migration[5.1]
  def change
    remove_index :process_signals, column: [:execution_id]
    add_index :process_signals, [:execution_id], unique: true
  end
end

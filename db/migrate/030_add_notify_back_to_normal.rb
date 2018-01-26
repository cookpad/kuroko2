class AddNotifyBackToNormal < ActiveRecord::Migration[5.0]
  def change
    add_column :job_instances, :retrying, :boolean, default: false, null: false
  end
end

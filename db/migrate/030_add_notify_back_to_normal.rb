class AddNotifyBackToNormal < ActiveRecord::Migration[5.1]
  def change
    add_column :job_definitions, :notify_back_to_normal, :boolean, default: false, null: false, after: :notify_cancellation
    add_column :job_instances, :retrying, :boolean
  end
end

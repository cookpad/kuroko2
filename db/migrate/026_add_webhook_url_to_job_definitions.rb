class AddWebhookUrlToJobDefinitions < ActiveRecord::Migration[5.0]
  def change
    add_column :job_definitions, :webhook_url, :text
  end
end

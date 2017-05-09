class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table "logs" do |t|
      t.integer  "job_instance_id", limit: 4
      t.string   "level",           limit: 10
      t.text     "message",         limit: 16777217 # this means MySQL LONGTEXT type and PostgreSQL TEXT type.
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logs", ["job_instance_id"], name: "job_instance_id", using: :btree
  end
end

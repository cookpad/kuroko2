class CreateExecutions < ActiveRecord::Migration[5.0]
  def change
    create_table "executions" do |t|
      t.string   "uuid",                   limit: 36,                              null: false
      t.integer  "job_definition_id",      limit: 4
      t.integer  "job_definition_version", limit: 4
      t.integer  "job_instance_id",        limit: 4
      t.integer  "token_id",               limit: 4
      t.string   "queue",                  limit: 180,        default: "@default", null: false
      t.text     "shell",                  limit: 65535,                           null: false
      t.text     "context",                limit: 65535,                           null: false
      t.integer  "pid",                    limit: 4
      t.text     "output",                 limit: 16777217
      t.integer  "exit_status",            limit: 1
      t.integer  "term_signal",            limit: 1
      t.datetime "started_at"
      t.datetime "finished_at"
      t.datetime "mailed_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "executions", ["job_definition_id", "token_id"], unique: true, using: :btree
    add_index "executions", ["started_at"], name: "started_at", using: :btree
  end
end

class CreateTokens < ActiveRecord::Migration
  def change
    create_table "tokens", options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.string   "uuid",                   limit: 36,                  null: false
      t.integer  "job_definition_id",      limit: 4
      t.integer  "job_definition_version", limit: 4
      t.integer  "job_instance_id",        limit: 4
      t.integer  "parent_id",              limit: 4
      t.text     "script",                 limit: 65535,               null: false
      t.string   "path",                   limit: 180,   default: "/", null: false
      t.integer  "status",                 limit: 4,     default: 0,   null: false
      t.text     "message",                limit: 65535,               null: false
      t.text     "context",                limit: 65535,               null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "tokens", ["parent_id"], name: "parent_id", using: :btree
    add_index "tokens", ["status"], name: "status", using: :btree
  end
end

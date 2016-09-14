class CreateProcessSignals < ActiveRecord::Migration
  def change
    create_table "process_signals", force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.string   "hostname",   limit: 180,   default: "", null: false
      t.integer  "pid",        limit: 4,                  null: false
      t.integer  "number",     limit: 1,     default: 15, null: false
      t.datetime "started_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "message",    limit: 65535
    end

    add_index "process_signals", ["hostname", "started_at"], name: "hostname_started_at", using: :btree
  end
end

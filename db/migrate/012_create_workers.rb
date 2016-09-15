class CreateWorkers < ActiveRecord::Migration
  def change
    create_table "workers" do |t|
      t.string   "hostname",     limit: 180,                      null: false
      t.integer  "worker_id",    limit: 1,                        null: false
      t.string   "queue",        limit: 180, default: "@default", null: false
      t.boolean  "working",                  default: false,      null: false
      t.integer  "execution_id", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "workers", ["hostname", "worker_id"], name: "hostname", unique: true, using: :btree
  end
end

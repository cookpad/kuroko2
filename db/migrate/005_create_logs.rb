class CreateLogs < ActiveRecord::Migration
  def change
    create_table "logs", force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.integer  "job_instance_id", limit: 4
      t.string   "level",           limit: 10
      t.text     "message",         limit: 4294967295
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "logs", ["job_instance_id"], name: "job_instance_id", using: :btree
  end
end

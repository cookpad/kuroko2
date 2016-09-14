class CreateJobInstances < ActiveRecord::Migration
  def change
    create_table "job_instances", force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.integer  "job_definition_id",      limit: 4
      t.integer  "job_definition_version", limit: 4
      t.text     "script",                 limit: 65535
      t.datetime "finished_at"
      t.datetime "canceled_at"
      t.datetime "error_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "job_instances", ["finished_at", "canceled_at", "job_definition_id"], name: "finished_at", using: :btree
    add_index "job_instances", ["job_definition_id"], name: "job_definition_id", using: :btree
  end
end

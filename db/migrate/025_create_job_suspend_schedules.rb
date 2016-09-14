class CreateJobSuspendSchedules < ActiveRecord::Migration
  def change
    create_table "job_suspend_schedules", options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.integer  "job_definition_id", limit: 4
      t.string   "cron",              limit: 180
      t.datetime "created_at",                    null: false
      t.datetime "updated_at",                    null: false
    end

    add_index "job_suspend_schedules", ["job_definition_id", "cron"], name: "job_definition_id", unique: true, using: :btree
  end
end

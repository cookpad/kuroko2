class CreateJobSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table "job_schedules" do |t|
      t.integer  "job_definition_id", limit: 4
      t.string   "cron",              limit: 180
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "job_schedules", ["job_definition_id", "cron"], name: 'kuroko2_schedules_definition_id_cron_idx', unique: true, using: :btree
  end
end



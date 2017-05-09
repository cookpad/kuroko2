class CreateJobDefinitions < ActiveRecord::Migration[5.0]
  def change
    create_table "job_definitions" do |t|
      t.integer  "version",                 limit: 4,     default: 0,     null: false
      t.string   "name",                    limit: 180,                   null: false
      t.text     "description",             limit: 65535,                 null: false
      t.text     "script",                  limit: 65535,                 null: false
      t.boolean  "suspended",                             default: false, null: false
      t.integer  "prevent_multi",           limit: 4,     default: 1,     null: false
      t.boolean  "notify_cancellation",                   default: true,  null: false
      t.string   "hipchat_room",            limit: 180,   default: "",    null: false
      t.boolean  "hipchat_notify_finished",               default: true,  null: false
      t.string   "hipchat_additional_text", limit: 180
      t.string   "slack_channel",           limit: 180,   default: "",    null: false
      t.boolean  "api_allowed",                           default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "job_definitions", ["name"], name: "name", using: :btree
  end
end

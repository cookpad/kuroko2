# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 25) do

  create_table "admin_assignments", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",           null: false, unsigned: true
    t.integer  "job_definition_id", null: false, unsigned: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "job_definition_id"], name: "user_id", unique: true, using: :btree
  end

  create_table "executions", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string   "uuid",                   limit: 36,                              null: false
    t.integer  "job_definition_id",                                                           unsigned: true
    t.integer  "job_definition_version",                                                      unsigned: true
    t.integer  "job_instance_id",                                                             unsigned: true
    t.integer  "token_id",                                                                    unsigned: true
    t.string   "queue",                  limit: 180,        default: "@default", null: false
    t.text     "shell",                  limit: 65535,                           null: false
    t.text     "context",                limit: 65535,                           null: false
    t.integer  "pid",                                                                         unsigned: true
    t.text     "output",                 limit: 4294967295
    t.integer  "exit_status",            limit: 1,                                            unsigned: true
    t.integer  "term_signal",            limit: 1
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "mailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_definition_id", "token_id"], name: "job_definition_id", unique: true, using: :btree
    t.index ["started_at"], name: "started_at", using: :btree
  end

  create_table "job_definition_tags", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "job_definition_id", null: false, unsigned: true
    t.integer  "tag_id",            null: false, unsigned: true
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["job_definition_id", "tag_id"], name: "job_definition_id", unique: true, using: :btree
    t.index ["tag_id"], name: "job_definition_tags_tag_id", using: :btree
  end

  create_table "job_definitions", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "version",                               default: 0,     null: false, unsigned: true
    t.string   "name",                    limit: 180,                   null: false
    t.text     "description",             limit: 65535,                 null: false
    t.text     "script",                  limit: 65535,                 null: false
    t.boolean  "suspended",                             default: false, null: false
    t.integer  "prevent_multi",                         default: 1,     null: false, unsigned: true
    t.boolean  "notify_cancellation",                   default: true,  null: false
    t.string   "hipchat_room",            limit: 180,   default: "",    null: false
    t.boolean  "hipchat_notify_finished",               default: true,  null: false
    t.string   "hipchat_additional_text", limit: 180
    t.string   "slack_channel",           limit: 180,   default: "",    null: false
    t.boolean  "api_allowed",                           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "name", using: :btree
  end

  create_table "job_instances", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "job_definition_id",                    unsigned: true
    t.integer  "job_definition_version",               unsigned: true
    t.text     "script",                 limit: 65535
    t.datetime "finished_at"
    t.datetime "canceled_at"
    t.datetime "error_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["finished_at", "canceled_at", "job_definition_id"], name: "finished_at", using: :btree
    t.index ["job_definition_id"], name: "job_definition_id", using: :btree
  end

  create_table "job_schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "job_definition_id",             unsigned: true
    t.string   "cron",              limit: 180
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_definition_id", "cron"], name: "job_definition_id", unique: true, using: :btree
  end

  create_table "job_suspend_schedules", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "job_definition_id",                          unsigned: true
    t.string   "cron",              limit: 180
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["job_definition_id", "cron"], name: "job_definition_id", unique: true, using: :btree
  end

  create_table "logs", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.integer  "job_instance_id",                    unsigned: true
    t.string   "level",           limit: 10
    t.text     "message",         limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_instance_id"], name: "job_instance_id", using: :btree
  end

  create_table "memory_consumption_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "job_instance_id"
    t.integer  "value",           null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["job_instance_id"], name: "index_memory_consumption_logs_on_job_instance_id", using: :btree
  end

  create_table "memory_expectancies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "expected_value",    default: 0, null: false
    t.integer  "job_definition_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["job_definition_id"], name: "index_memory_expectancies_on_job_definition_id", using: :btree
  end

  create_table "process_signals", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string   "hostname",   limit: 180,   default: "", null: false
    t.integer  "pid",                                   null: false, unsigned: true
    t.integer  "number",     limit: 1,     default: 15, null: false, unsigned: true
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message",    limit: 65535
    t.index ["hostname", "started_at"], name: "hostname_started_at", using: :btree
  end

  create_table "stars", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id",           null: false, unsigned: true
    t.integer  "job_definition_id", null: false, unsigned: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "job_definition_id"], name: "user_id", unique: true, using: :btree
  end

  create_table "tags", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", comment: "2014-05-22 Hiromu Shioya" do |t|
    t.string   "name",       limit: 100, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["name"], name: "name", unique: true, using: :btree
  end

  create_table "ticks", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.datetime "at"
  end

  create_table "tokens", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC" do |t|
    t.string   "uuid",                   limit: 36,                  null: false
    t.integer  "job_definition_id",                                               unsigned: true
    t.integer  "job_definition_version",                                          unsigned: true
    t.integer  "job_instance_id",                                                 unsigned: true
    t.integer  "parent_id"
    t.text     "script",                 limit: 65535,               null: false
    t.string   "path",                   limit: 180,   default: "/", null: false
    t.integer  "status",                               default: 0,   null: false
    t.text     "message",                limit: 65535,               null: false
    t.text     "context",                limit: 65535,               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parent_id"], name: "parent_id", using: :btree
    t.index ["status"], name: "status", using: :btree
  end

  create_table "users", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "provider",     limit: 180, default: "google_oauth2", null: false
    t.string   "uid",          limit: 180,                           null: false
    t.string   "name",         limit: 180, default: "",              null: false
    t.string   "email",        limit: 180,                           null: false
    t.string   "first_name",   limit: 180, default: "",              null: false
    t.string   "last_name",    limit: 180, default: "",              null: false
    t.string   "image",        limit: 180, default: "",              null: false
    t.datetime "suspended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "email", unique: true, using: :btree
    t.index ["uid", "suspended_at"], name: "uid_2", using: :btree
    t.index ["uid"], name: "uid", unique: true, using: :btree
  end

  create_table "workers", unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "hostname",     limit: 180,                      null: false
    t.integer  "worker_id",    limit: 1,                        null: false
    t.string   "queue",        limit: 180, default: "@default", null: false
    t.boolean  "working",                  default: false,      null: false
    t.integer  "execution_id",                                               unsigned: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["hostname", "worker_id"], name: "hostname", unique: true, using: :btree
  end

end

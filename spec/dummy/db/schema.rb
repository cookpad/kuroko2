# encoding: UTF-8
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

  create_table "admin_assignments", force: :cascade do |t|
    t.integer  "user_id",           limit: 4, null: false
    t.integer  "job_definition_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_assignments", ["user_id", "job_definition_id"], name: "user_id", unique: true, using: :btree

  create_table "executions", force: :cascade do |t|
    t.string   "uuid",                   limit: 36,                              null: false
    t.integer  "job_definition_id",      limit: 4
    t.integer  "job_definition_version", limit: 4
    t.integer  "job_instance_id",        limit: 4
    t.integer  "token_id",               limit: 4
    t.string   "queue",                  limit: 180,        default: "@default", null: false
    t.text     "shell",                  limit: 65535,                           null: false
    t.text     "context",                limit: 65535,                           null: false
    t.integer  "pid",                    limit: 4
    t.text     "output",                 limit: 4294967295
    t.integer  "exit_status",            limit: 1
    t.integer  "term_signal",            limit: 1
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "mailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "executions", ["job_definition_id", "token_id"], name: "job_definition_id", unique: true, using: :btree
  add_index "executions", ["started_at"], name: "started_at", using: :btree

  create_table "job_definition_tags", force: :cascade do |t|
    t.integer  "job_definition_id", limit: 4, null: false
    t.integer  "tag_id",            limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "job_definition_tags", ["job_definition_id", "tag_id"], name: "job_definition_id", unique: true, using: :btree
  add_index "job_definition_tags", ["tag_id"], name: "job_definition_tags_tag_id", using: :btree

  create_table "job_definitions", force: :cascade do |t|
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

  create_table "job_instances", force: :cascade do |t|
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

  create_table "job_schedules", force: :cascade do |t|
    t.integer  "job_definition_id", limit: 4
    t.string   "cron",              limit: 180
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_schedules", ["job_definition_id", "cron"], name: "job_definition_id", unique: true, using: :btree

  create_table "job_suspend_schedules", force: :cascade do |t|
    t.integer  "job_definition_id", limit: 4
    t.string   "cron",              limit: 180
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "job_suspend_schedules", ["job_definition_id", "cron"], name: "job_definition_id", unique: true, using: :btree

  create_table "logs", force: :cascade do |t|
    t.integer  "job_instance_id", limit: 4
    t.string   "level",           limit: 10
    t.text     "message",         limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["job_instance_id"], name: "job_instance_id", using: :btree

  create_table "memory_consumption_logs", force: :cascade do |t|
    t.integer  "job_instance_id", limit: 4
    t.integer  "value",           limit: 4, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "memory_consumption_logs", ["job_instance_id"], name: "index_memory_consumption_logs_on_job_instance_id", using: :btree

  create_table "memory_expectancies", force: :cascade do |t|
    t.integer  "expected_value",    limit: 4, default: 0, null: false
    t.integer  "job_definition_id", limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "memory_expectancies", ["job_definition_id"], name: "index_memory_expectancies_on_job_definition_id", using: :btree

  create_table "process_signals", force: :cascade do |t|
    t.string   "hostname",   limit: 180,   default: "", null: false
    t.integer  "pid",        limit: 4,                  null: false
    t.integer  "number",     limit: 1,     default: 15, null: false
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message",    limit: 65535
  end

  add_index "process_signals", ["hostname", "started_at"], name: "hostname_started_at", using: :btree

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id",           limit: 4, null: false
    t.integer  "job_definition_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stars", ["user_id", "job_definition_id"], name: "user_id", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 100, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "tags", ["name"], name: "name", unique: true, using: :btree

  create_table "ticks", force: :cascade do |t|
    t.datetime "at"
  end

  create_table "tokens", force: :cascade do |t|
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

  create_table "users", force: :cascade do |t|
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
  end

  add_index "users", ["email"], name: "email", unique: true, using: :btree
  add_index "users", ["uid", "suspended_at"], name: "uid_2", using: :btree
  add_index "users", ["uid"], name: "uid", unique: true, using: :btree

  create_table "workers", force: :cascade do |t|
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

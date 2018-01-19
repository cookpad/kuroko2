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

ActiveRecord::Schema.define(version: 30) do

  create_table "admin_assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "user_id", null: false
    t.integer "job_definition_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "job_definition_id"], name: "user_id", unique: true
  end

  create_table "executions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "uuid", limit: 36, null: false
    t.integer "job_definition_id"
    t.integer "job_definition_version"
    t.integer "job_instance_id"
    t.integer "token_id"
    t.string "queue", limit: 180, default: "@default", null: false
    t.text "shell", null: false
    t.text "context", null: false
    t.integer "pid"
    t.text "output", limit: 4294967295
    t.integer "exit_status", limit: 2
    t.integer "term_signal", limit: 1
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "mailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_definition_id", "token_id"], name: "index_kuroko2_executions_on_job_definition_id_and_token_id", unique: true
    t.index ["started_at"], name: "started_at"
  end

  create_table "job_definition_tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_definition_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_definition_id", "tag_id"], name: "kuroko2_definition_tag_idx", unique: true
    t.index ["tag_id"], name: "job_definition_tags_tag_id"
  end

  create_table "job_definitions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "version", default: 0, null: false
    t.string "name", limit: 180, null: false
    t.text "description", null: false
    t.text "script", null: false
    t.boolean "suspended", default: false, null: false
    t.integer "prevent_multi", default: 1, null: false
    t.boolean "notify_cancellation", default: true, null: false
    t.boolean "notify_back_to_normal", default: false, null: false
    t.string "hipchat_room", limit: 180, default: "", null: false
    t.boolean "hipchat_notify_finished", default: true, null: false
    t.string "hipchat_additional_text", limit: 180
    t.string "slack_channel", limit: 180, default: "", null: false
    t.boolean "api_allowed", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "webhook_url"
    t.index ["name"], name: "name"
  end

  create_table "job_instances", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_definition_id"
    t.integer "job_definition_version"
    t.text "script"
    t.datetime "finished_at"
    t.datetime "canceled_at"
    t.datetime "error_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["finished_at", "canceled_at", "job_definition_id"], name: "job_instance_idx"
    t.index ["job_definition_id"], name: "index_kuroko2_job_instances_on_job_definition_id"
  end

  create_table "job_schedules", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_definition_id"
    t.string "cron", limit: 180
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_definition_id", "cron"], name: "kuroko2_schedules_definition_id_cron_idx", unique: true
  end

  create_table "job_suspend_schedules", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_definition_id"
    t.string "cron", limit: 180
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_definition_id", "cron"], name: "kuroko2_suspend_schedules_definition_id_cron_idx", unique: true
  end

  create_table "logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_instance_id"
    t.string "level", limit: 10
    t.text "message", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["job_instance_id"], name: "job_instance_id"
  end

  create_table "memory_consumption_logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "job_instance_id"
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_instance_id"], name: "index_kuroko2_memory_consumption_logs_on_job_instance_id"
  end

  create_table "memory_expectancies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "expected_value", default: 0, null: false
    t.integer "job_definition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_definition_id"], name: "index_kuroko2_memory_expectancies_on_job_definition_id"
  end

  create_table "process_signals", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "hostname", limit: 180, default: "", null: false
    t.integer "pid", null: false
    t.integer "number", limit: 1, default: 15, null: false
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "message"
    t.integer "execution_id"
    t.index ["execution_id"], name: "index_kuroko2_process_signals_on_execution_id"
    t.index ["hostname", "started_at"], name: "hostname_started_at"
  end

  create_table "stars", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "user_id", null: false
    t.integer "job_definition_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "job_definition_id"], name: "index_kuroko2_stars_on_user_id_and_job_definition_id", unique: true
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "name", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_kuroko2_tags_on_name", unique: true
  end

  create_table "ticks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.datetime "at"
  end

  create_table "tokens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "uuid", limit: 36, null: false
    t.integer "job_definition_id"
    t.integer "job_definition_version"
    t.integer "job_instance_id"
    t.integer "parent_id"
    t.text "script", null: false
    t.string "path", limit: 180, default: "/", null: false
    t.integer "status", default: 0, null: false
    t.text "message", null: false
    t.text "context", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parent_id"], name: "parent_id"
    t.index ["status"], name: "status"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "provider", limit: 180, default: "google_oauth2", null: false
    t.string "uid", limit: 180, null: false
    t.string "name", limit: 180, default: "", null: false
    t.string "email", limit: 180, null: false
    t.string "first_name", limit: 180, default: "", null: false
    t.string "last_name", limit: 180, default: "", null: false
    t.string "image", limit: 180, default: "", null: false
    t.datetime "suspended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "email"
    t.index ["uid", "suspended_at"], name: "uid_2"
    t.index ["uid"], name: "uid", unique: true
  end

  create_table "workers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "hostname", limit: 180, null: false
    t.integer "worker_id", limit: 1, null: false
    t.string "queue", limit: 180, default: "@default", null: false
    t.boolean "working", default: false, null: false
    t.integer "execution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["hostname", "worker_id"], name: "hostname", unique: true
  end

end

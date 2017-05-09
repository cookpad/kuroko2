class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table "users" do |t|
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
  end
end

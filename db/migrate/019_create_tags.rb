class CreateTags < ActiveRecord::Migration
  def change
    create_table "tags", force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.string   "name",       limit: 100, null: false
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    add_index "tags", ["name"], name: "name", unique: true, using: :btree
  end
end

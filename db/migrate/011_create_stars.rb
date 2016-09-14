class CreateStars < ActiveRecord::Migration
  def change
    create_table "stars", options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.integer  "user_id",           limit: 4, null: false
      t.integer  "job_definition_id", limit: 4, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "stars", ["user_id", "job_definition_id"], name: "user_id", unique: true, using: :btree
  end
end

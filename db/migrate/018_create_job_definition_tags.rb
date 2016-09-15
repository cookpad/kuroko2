class CreateJobDefinitionTags < ActiveRecord::Migration
  def change
    create_table "job_definition_tags" do |t|
      t.integer  "job_definition_id", limit: 4, null: false
      t.integer  "tag_id",            limit: 4, null: false
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
    end

    add_index "job_definition_tags", ["job_definition_id", "tag_id"], name: 'kuroko2_definition_tag_idx', unique: true, using: :btree
    add_index "job_definition_tags", ["tag_id"], name: "job_definition_tags_tag_id", using: :btree
  end
end

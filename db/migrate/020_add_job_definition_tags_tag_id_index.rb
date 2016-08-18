class AddJobDefinitionTagsTagIdIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE INDEX job_definition_tags_tag_id ON job_definition_tags(tag_id)
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX job_definition_tags_tag_id ON job_definition_tags
    SQL
  end
end

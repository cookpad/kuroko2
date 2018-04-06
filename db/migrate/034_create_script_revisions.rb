class CreateScriptRevisions < ActiveRecord::Migration[5.1]
  def up
    create_table :script_revisions do |t|
      t.belongs_to :job_definition, foreign_key: true, null: false
      t.text :script, null: false
      t.belongs_to :user, foreign_key: true, null: true
      t.datetime :changed_at, null: false

      t.timestamps null: false
    end

    Kuroko2::JobDefinition.all.each do |definition|
      Kuroko2::ScriptRevision.create(job_definition: definition, script: definition.script, changed_at: definition.updated_at)
    end
  end

  def down
    drop_table :script_revisions
  end
end

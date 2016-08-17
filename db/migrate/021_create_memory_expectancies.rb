class CreateMemoryExpectancies < ActiveRecord::Migration
  def change
    create_table :memory_expectancies do |t|
      t.integer :expected_value, null: false, default: 0
      t.references :job_definition, index: true

      t.timestamps null: false
    end

    create_table :memory_consumption_logs do |t|
      t.references :job_instance, index: true
      t.integer :value, null: false

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        # The mysql server's timezone is JST, and AR's timezone is set as UTC
        # Same as:
        #   JobDefinition.find_each {|definition| definition.create_memory_expectancy! }
        execute <<-SQL
          INSERT INTO `memory_expectancies`
            (`job_definition_id`, `created_at`, `updated_at`)
            SELECT `id`, UTC_TIMESTAMP(), UTC_TIMESTAMP() FROM `job_definitions`
          ;
        SQL
      end
    end
  end
end

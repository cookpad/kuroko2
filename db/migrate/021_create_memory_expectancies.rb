class CreateMemoryExpectancies < ActiveRecord::Migration
  def change
    create_table :memory_expectancies, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.integer :expected_value, null: false, default: 0
      t.references :job_definition, index: true

      t.timestamps null: false
    end

    create_table :memory_consumption_logs, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.references :job_instance, index: true
      t.integer :value, null: false

      t.timestamps null: false
    end
  end
end

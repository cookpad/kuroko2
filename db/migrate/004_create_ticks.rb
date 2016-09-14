class CreateTicks < ActiveRecord::Migration
  def change
    create_table "ticks", force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC' do |t|
      t.datetime "at"
    end
  end
end

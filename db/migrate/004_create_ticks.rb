class CreateTicks < ActiveRecord::Migration[5.0]
  def change
    create_table "ticks" do |t|
      t.datetime "at"
    end
  end
end

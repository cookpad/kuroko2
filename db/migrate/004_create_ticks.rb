class CreateTicks < ActiveRecord::Migration
  def change
    create_table "ticks" do |t|
      t.datetime "at"
    end
  end
end

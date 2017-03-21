class DropUniqConstraintUserEmail < ActiveRecord::Migration
  def up
    remove_index :users, name: "email"
    add_index :users, :email, name: "email", using: :btree
  end
end

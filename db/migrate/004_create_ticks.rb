class CreateTicks < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE ticks (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        at DATETIME,

        PRIMARY KEY (id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS ticks;
    SQL
  end
end

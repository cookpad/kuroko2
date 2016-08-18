class CreateTags < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE tags (
        id         INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        name       VARCHAR(100) NOT NULL,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY(name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS tags;
    SQL
  end
end

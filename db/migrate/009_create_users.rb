class CreateUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE users (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        provider VARCHAR(180) NOT NULL DEFAULT 'google_oauth2',
        uid      VARCHAR(180) NOT NULL,

        name       VARCHAR(180) NOT NULL DEFAULT '',
        email      VARCHAR(180) NOT NULL,
        first_name VARCHAR(180) NOT NULL DEFAULT '',
        last_name  VARCHAR(180) NOT NULL DEFAULT '',
        image      VARCHAR(180) NOT NULL DEFAULT '',

        suspended_at DATETIME,
        created_at   DATETIME,
        updated_at   DATETIME,

        PRIMARY KEY(id),
        UNIQUE(uid),
        UNIQUE(email),
        KEY(uid, suspended_at)
      )
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS users;
    SQL
  end
end

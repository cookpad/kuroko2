class CreateWorkers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE workers (
        id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,

        hostname     VARCHAR(180) NOT NULL,
        worker_id    TINYINT      NOT NULL,
        queue        VARCHAR(180) NOT NULL DEFAULT '@default',
        working      BOOLEAN      NOT NULL DEFAULT false,

        execution_id INTEGER UNSIGNED,

        created_at   DATETIME,
        updated_at   DATETIME,

        PRIMARY KEY(id),
        UNIQUE(hostname, worker_id)
      )
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE IF EXISTS workers;
    SQL
  end
end

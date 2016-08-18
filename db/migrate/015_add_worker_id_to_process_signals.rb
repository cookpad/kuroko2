class AddWorkerIdToProcessSignals < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE process_signals ADD COLUMN hostname varchar(180) NOT NULL DEFAULT '' AFTER id
    SQL
    execute <<-SQL
      DROP INDEX started_at ON process_signals
    SQL
    execute <<-SQL
      CREATE INDEX hostname_started_at ON process_signals(hostname, started_at)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE process_signals DROP COLUMN hostname
    SQL
    execute <<-SQL
      CREATE INDEX started_at ON process_signals(started_at)
    SQL
  end
end

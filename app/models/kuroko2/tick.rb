class Tick < ActiveRecord::Base

  def self.fetch_then_update(now)
    tick = self.first_or_create
    last = tick.at || now

    tick.update_column(:at, now)
    last
  end

end

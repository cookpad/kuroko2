class Kuroko2::Tick < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  def self.fetch_then_update(now)
    tick = self.first_or_create
    last = tick.at || now

    tick.update_column(:at, now)
    last
  end

end

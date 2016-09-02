class Kuroko2::Worker < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :execution

  scope :on, -> (hostname) { where(hostname: hostname) }
  scope :ordered, -> { order(:hostname, :worker_id) }

  def self.executing(id)
    where(execution_id: id).take
  end
end

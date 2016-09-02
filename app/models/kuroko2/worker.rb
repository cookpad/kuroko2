class Worker < ActiveRecord::Base
  belongs_to :execution

  scope :on, -> (hostname) { where(hostname: hostname) }
  scope :ordered, -> { order(:hostname, :worker_id) }

  def self.executing(id)
    where(execution_id: id).take
  end
end

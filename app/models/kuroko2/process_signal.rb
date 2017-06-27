class Kuroko2::ProcessSignal < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :execution

  scope :unstarted, -> { where(started_at: nil) }
  scope :on, ->(hostname) { joins(execution: :worker).merge(Kuroko2::Worker.on(hostname)) }

  def self.poll(hostname)
    self.transaction do
      unstarted.on(hostname).lock.take.tap do |signal|
        signal.touch(:started_at) if signal
      end
    end
  end
end

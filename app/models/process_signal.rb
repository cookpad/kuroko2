class ProcessSignal < ActiveRecord::Base
  scope :unstarted, -> { where(started_at: nil) }
  scope :on, ->(hostname) { where(hostname: hostname) }

  def self.poll(hostname)
    self.transaction do
      unstarted.on(hostname).lock.take.tap do |signal|
        signal.touch(:started_at) if signal
      end
    end
  end
end

class Kuroko2::Execution < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  DEFAULT_QUEUE = '@default'

  scope :of, ->(token) { where(token: token) }
  scope :with, ->(queue) { where(queue: queue) }
  scope :unstarted, -> { where(started_at: nil) }
  scope :started, -> { where.not(started_at: nil) }

  serialize :context, JSON

  belongs_to :job_definition
  belongs_to :job_instance
  belongs_to :token

  has_one :worker

  before_create :set_default_values

  delegate :log_memory_consumption, to: :job_instance

  def completed?
    started_at? && finished_at?
  end

  def success?
    exit_status == 0
  end

  def self.poll(queue = DEFAULT_QUEUE)
    self.transaction do
      unstarted.with(queue).lock.take.tap do |execution|
        execution.touch(:started_at) if execution
      end
    end
  end

  def finish(output:, exit_status:)
    update!(output: output, exit_status: exit_status, finished_at: Time.now)
    job_definition.memory_expectancy.calculate!
  end

  def finish_by_signal(output:, term_signal:)
    update!(output: output, term_signal: term_signal, finished_at: Time.now)
    job_definition.memory_expectancy.calculate!
  end

  private

  def set_default_values
    self.uuid    ||= SecureRandom.uuid
    self.context ||= {}
  end
end

class Kuroko2::JobInstance < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition

  attr_accessor :log_message

  has_many :logs, dependent: :delete_all do
    def info(message)
      add('INFO', message)
    end

    def warn(message)
      add('WARN', message)
    end

    def error(message)
      add('ERROR', message)
    end

    private
    def add(level, message)
      self.create(level: level, message: message)
    end
  end
  has_many :tokens, dependent: :restrict_with_exception
  has_many :executions, dependent: :restrict_with_exception
  has_one :memory_consumption_log, dependent: :destroy

  before_create :copy_script
  after_create :notify_launch
  after_create :generate_token

  scope :working, -> { where(finished_at: nil, canceled_at: nil) }
  scope :finished, -> { where.not(finished_at: nil) }

  def error?
    working? && error_at?
  end

  def working?
    !finished_at? && !canceled_at?
  end

  def cancelable?
    tokens.first.try(:cancelable?)
  end

  def cancel(by:)
    self.tokens.destroy(*self.tokens)
    self.executions.destroy(*self.executions)
    self.touch(:canceled_at)

    message = "This job was canceled by #{by}."
    self.logs.warn(message)
    Kuroko2.logger.warn(message)
  end

  # Log given value if it is greater than stored one.
  # This logging is not so important that we can ignore race condition,
  # so we use `#update` and `#create_association` without bang here.
  # @param [Intger] value
  def log_memory_consumption(value)
    if memory_consumption_log
      max = [value, memory_consumption_log.value].max
      memory_consumption_log.update(value: max)
    else
      create_memory_consumption_log(value: value)
    end
  end

  def execution_minutes
    (((error_at || canceled_at || finished_at || Time.current) - created_at).to_f / 60).round(2)
  end

  def status
    if finished_at?
      'success'
    elsif canceled_at?
      'canceled'
    elsif error_at?
      'error'
    else
      'working'
    end
  end

  private

  def copy_script
    self.script = job_definition.try(:script) if self.script.blank?
  end

  def notify_launch
    if log_message
      Kuroko2.logger.info(log_message)
      self.logs.info(log_message)
      Kuroko2::Workflow::Notifier.notify(:launch, self)
    end
  end

  def generate_token
    unless self.job_definition
      raise 'No parent association is found'
    end

    if job_definition.proceed_multi_instance?
      self.tokens << Kuroko2::Token.new do |token|
        definition = self.job_definition

        token.job_definition         = definition
        token.job_definition_version = definition.version
        token.script                 = self.script
        token.context                = {
          meta: {
            launched_time:       Time.current,
            job_definition_id:   definition.id,
            job_definition_name: definition.name,
            job_instance_id:     id,
          }
        }
      end
    else
      self.touch(:canceled_at)

      message = 'This job was canceled because there is already a working or erred job instance.'
      self.logs.warn(message)
      Kuroko2.logger.warn(message)

      Kuroko2::Workflow::Notifier.notify(:cancellation, self)
    end
  end
end

class Token < ActiveRecord::Base
  WORKING  = 0
  FINISHED = 1
  FAILURE  = 2
  WAITING  = 3
  CRITICAL = 9

  STATUSES = {
    WORKING  => :working,
    FINISHED => :finished,
    FAILURE  => :failure,
    CRITICAL => :critical,
    WAITING  => :waiting,
  }.freeze

  serialize :context, JSON

  belongs_to :job_definition
  belongs_to :job_instance

  has_many :children, class_name: 'Token', foreign_key: 'parent_id', dependent: :destroy
  belongs_to :parent, class_name: 'Token'

  has_one :execution

  before_create :set_default_values

  scope :processable, -> { where(status: [WORKING, WAITING])}
  scope :working, -> { where(status: WORKING) }
  scope :finished, -> { where(status: FINISHED) }
  scope :waiting, -> { where(status: WAITING) }

  def working?
    status == WORKING
  end

  def failure?
    status == FAILURE
  end

  def finished?
    status == FINISHED
  end

  def critical?
    status == CRITICAL
  end

  def waiting?
    status == WAITING
  end

  def mark_as_failure
    self.status = FAILURE
  end

  def mark_as_critical(error)
    self.status  = CRITICAL
    self.message = error.message
  end

  def mark_as_finished
    self.status = FINISHED
  end

  def mark_as_working
    self.status = WORKING
  end

  def mark_as_waiting
    self.status = WAITING
  end

  def status_name
    STATUSES[status].to_s
  end

  def cancelable?
    case status
    when WORKING, WAITING
      children.many? && children.all? do |child|
        child.status == FINISHED || child.cancelable?
      end
    when FAILURE
      true
    else
      false
    end
  end

  private

  def set_default_values
    self.uuid    ||= SecureRandom.uuid
    self.message ||= ''
    self.context ||= {}
    self.status  ||= WORKING
  end
end

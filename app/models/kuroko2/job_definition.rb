class Kuroko2::JobDefinition < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  module PreventMultiStatus
    NONE = 0
    WORKING_OR_ERROR = 1
    WORKING = 2
    ERROR = 3
  end

  PREVENT_TOKEN_STATUSES = {
    PreventMultiStatus::NONE => [],
    PreventMultiStatus::WORKING_OR_ERROR => [
      Kuroko2::Token::WORKING,
      Kuroko2::Token::FAILURE,
      Kuroko2::Token::CRITICAL
    ],
    PreventMultiStatus::WORKING => [Kuroko2::Token::WORKING],
    PreventMultiStatus::ERROR => [Kuroko2::Token::FAILURE, Kuroko2::Token::CRITICAL],
  }

  self.locking_column = :version

  paginates_per 100

  has_many :admin_assignments, dependent: :destroy
  has_many :admins, -> { active }, through: :admin_assignments, source: :user
  has_many :job_instances, -> { order(:id).reverse_order }
  has_many :job_schedules, dependent: :delete_all
  has_many :job_suspend_schedules, dependent: :delete_all
  has_many :job_definition_tags
  has_many :tags, through: :job_definition_tags
  has_many :revisions, -> { order(id: :desc) }, class_name: 'ScriptRevision', dependent: :destroy
  has_one :memory_expectancy, dependent: :destroy

  before_destroy :confirm_active_instances
  after_initialize :set_default_values
  after_save :create_default_memory_expectancy, on: :create

  scope :ordered, -> { order(:id) }
  scope :tagged_by, ->(tags) {
    where(
      id: Kuroko2::JobDefinitionTag.
        where(tag_id: Kuroko2::Tag.where(name: tags).pluck(:id)).
        group(:job_definition_id).
        having('COUNT(1) >= ?', tags.size).
        pluck(:job_definition_id)
    )
  }
  scope :search_by, ->(query) {
    column = arel_table
    or_query = column[:name].matches("%#{query}%").or(column[:script].matches("%#{query}%"))

    search_by_tag_definition_ids = Kuroko2::JobDefinitionTag.joins(:tag).
      where("#{Kuroko2::Tag.table_name}.name LIKE ?", "%#{query}%").distinct.pluck(:job_definition_id)

    if search_by_tag_definition_ids.present?
      or_query = or_query.or(column[:id].in(search_by_tag_definition_ids))
    end

    where(or_query)
  }


  validates :name, length: { maximum: 180 }, presence: true
  validates :description, presence: true
  validates :script, presence: true
  validate :script_syntax
  validate :validate_number_of_admins
  validates :hipchat_additional_text, length: { maximum: 180 }
  validates :slack_channel,
    length: { maximum: 22, too_long: ' is too long (maximum is 21 characters without `#` symbol at the head)' },
    format: {
      with: /\A#[^\.\s]+\z/, allow_blank: true,
      message: ' must start with # and must not include any dots or spaces'
    }
  validates :webhook_url, format: { with: /\A#{URI::regexp(%w(http https))}\z/, allow_blank: true }

  def proceed_multi_instance?
    tokens = Kuroko2::Token.where(job_definition_id: self.id)
    (tokens.map(&:status) & PREVENT_TOKEN_STATUSES[self.prevent_multi]).empty?
  end

  def text_tags
    tags.map(&:name).join(',')
  end

  def text_tags=(text_tags)
    self.tags = text_tags.gsub(/[[:blank:]]+/, '').split(/[,、]/).uniq.map do |name|
      Kuroko2::Tag.find_or_create_by(name: name)
    end
  end

  def create_instance(script: nil, launched_by:, token: nil )
    message = "Launched by #{launched_by}"

    if token.present?
      message = "(token #{token.uuid}) #{message}"
    end

    job_instances.create!(script: script, log_message: message)
  end

  def save_and_record_revision(edited_user: nil)
    record_revision(edited_user: edited_user)
    save
  end

  def update_and_record_revision(attributes, edited_user: nil)
    assign_attributes(attributes)
    record_revision(edited_user: edited_user)
    save
  end

  private

  def confirm_active_instances
    if Kuroko2::Token.joins(:job_instance).merge(job_instances).exists?
      errors.add(:base, I18n.t('model.job_definition.confirm_active_instances'))
      throw :abort
    end
  end

  def set_default_values
    self.description ||= <<-EOF.strip_heredoc
      An description of the job definition.

      ## Failure Affects
      Affected users, services and/ or business areas.

      ## Workaround
      Choose one of the following:
      - __Retry__ as soon as possible.
      - Make an urgent call to administrator (Job stays in _Error_ state)
      - Do nothing, and let administrator recover later (Job stays in _Error_ state)
      - Ignore error and _Cancel_ the job (No recovery required)

      ## Recovery Procedures
      Describe how to recover from the failure.
    EOF
  end

  def record_revision(edited_user: nil)
    unless revisions.first.try(:script) == script
      revisions.new(script: script, user: edited_user, changed_at: Time.current)
    end
  end

  def create_default_memory_expectancy
    create_memory_expectancy! unless memory_expectancy
  end

  def script_syntax
    Kuroko2::Workflow::ScriptParser.new(script).parse

    true
  rescue Kuroko2::Workflow::SyntaxError => e
    errors.add(:base, I18n.t('model.job_definition.script_syntax', reason: e.message))

    false
  rescue Kuroko2::Workflow::AssertionError => e
    errors.add(:base, I18n.t('model.job_definition.validation_error', reason: e.message))

    false
  end

  def validate_number_of_admins
    if self.admins.empty?
      errors.add(:admins, I18n.t('model.job_definition.validate_number_of_admins'))
    end
  end
end

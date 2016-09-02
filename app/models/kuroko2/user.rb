class Kuroko2::User < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  GRAVATAR_URL = '//www.gravatar.com/avatar/%s?s=90&d=mm'
  GOOGLE_OAUTH2_PROVIDER = 'google_oauth2'
  GROUP_PROVIDER = 'group_mail'

  paginates_per 100

  scope :active, -> { where(suspended_at: nil) }
  scope :with, -> (ids) { where(id: ids) }
  scope :group_user, -> { where(provider: GROUP_PROVIDER) }

  has_many :stars
  has_many :job_definitions, through: :stars

  has_many :admin_assignments, dependent: :restrict_with_error
  has_many :assigned_job_definitions, through: :admin_assignments, source: :job_definition

  validates :name, uniqueness: { case_sensitive: false} , presence: true
  validates :email, uniqueness: { case_sensitive: false}, presence: true

  before_create :set_gravatar_image

  def self.find_or_create_user(uid, attributes)
    find_or_create_by(uid: uid) do |user|
      user.name       = attributes[:name]
      user.email      = attributes[:email]
      user.first_name = attributes[:first_name]
      user.last_name  = attributes[:last_name]
    end
  end

  def google_account?
    self.provider == GOOGLE_OAUTH2_PROVIDER
  end

  private

  def set_gravatar_image
    self.image = gravatar_url(self.email)
  end

  def gravatar_url(email)
    GRAVATAR_URL % Digest::MD5::hexdigest(email.strip.downcase)
  end

end

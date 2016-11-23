class Kuroko2::Tag < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  has_many :job_definition_tags
  has_many :job_definitions, through: :job_definition_tags, dependent: :destroy

  validates :name, length: { maximum: 100 }
end

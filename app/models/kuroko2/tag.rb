class Tag < ActiveRecord::Base
  has_many :job_definition_tags
  has_many :job_definitions, through: :job_definition_tags

  validates :name, length: { maximum: 100 }
end

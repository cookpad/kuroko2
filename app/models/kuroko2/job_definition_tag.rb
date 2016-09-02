class Kuroko2::JobDefinitionTag < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :tag
  belongs_to :job_definition
end

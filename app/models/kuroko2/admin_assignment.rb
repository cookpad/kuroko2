class Kuroko2::AdminAssignment < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition
  belongs_to :user
end

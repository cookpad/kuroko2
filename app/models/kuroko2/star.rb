class Kuroko2::Star < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :user
  belongs_to :job_definition
end

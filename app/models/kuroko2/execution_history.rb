class Kuroko2::ExecutionHistory < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition
  belongs_to :job_instance

  scope :ordered, -> { order(started_at: :desc) }
end

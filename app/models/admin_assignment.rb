class AdminAssignment < ActiveRecord::Base
  belongs_to :job_definition
  belongs_to :user
end

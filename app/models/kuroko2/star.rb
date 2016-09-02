class Star < ActiveRecord::Base
  belongs_to :user
  belongs_to :job_definition
end

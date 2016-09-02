class JobDefinitionTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :job_definition
end

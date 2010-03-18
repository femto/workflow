class WorkflowDefinition < ActiveRecord::Base
  puts "loaded activeRecord WorkflowDefinition"
  has_many :workflow_instances

  has_many :workflow_step_definitions
end

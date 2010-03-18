class WorkflowTransitionDefinition < ActiveRecord::Base
  belongs_to :workflow_step_definition
end
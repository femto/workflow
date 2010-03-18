class WorkflowStepDefinition < ActiveRecord::Base
  has_many :workflow_steps
  has_many :workflow_transition_definitions

  belongs_to :workflow_definition
end

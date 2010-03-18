class WorkflowStep < ActiveRecord::Base
  belongs_to :workflow_instance

  belongs_to :workflow_step_definition

  belongs_to :document, :polymorphic => true
end
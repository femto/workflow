load 'workflow/workflow_engine.rb'
load 'workflow/active_record_workflow_store.rb'

class WorkflowDefinition < ActiveRecord::Base
  #puts "loaded activeRecord WorkflowDefinition"
  has_many :workflow_instances

  has_many :workflow_step_definitions

  def start(transition_name, document=nil)
    $engine.store.start(self, transition_name, document)
  end
end

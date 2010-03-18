require 'workflow_store'

class ActiveRecordWorkflowStore < AbstractWorkflowStore
  register(:activerecord_store, self)

#  class WorkflowDefinition < ActiveRecord::Base
#    has_many :workflow_instances
#  end

  def load_workflow_definition(workflow_definition)
    if find_workflow_definition(workflow_definition.name, workflow_definition.version)
      Merb.logger.warn("already defined workflow_definition #{workflow_definition.name} v#{workflow_definition.version} in store")
      return
    end
    workflow_def = WorkflowDefinition.new
    workflow_def.name = workflow_definition.name
    workflow_def.version = workflow_definition.version

    workflow_def.save!

    workflow_definition.nodes.each do |node|
      workflow_step_definition = WorkflowStepDefinition.new
      workflow_step_definition.name = node.nodename
      workflow_step_definition.participant_definition = node.participant_definition
      workflow_step_definition.condition = node.condition
      workflow_step_definition.workflow_definition = workflow_def
      workflow_step_definition.save!
      #attach some information to memory node
      class << node
        attr_accessor :workflow_step_definition_id
      end
      node.workflow_step_definition_id = workflow_step_definition.id


    end
    workflow_definition.nodes.each do |node|
      node.transitions.each do |transition|
        transition_definition = WorkflowTransitionDefinition.new
        transition_definition.name = transition.name
        transition_definition.to_step_id = transition.to.workflow_step_definition_id
        transition_definition.workflow_step_definition_id =  node.workflow_step_definition_id
        transition_definition.save!
      end
    end
    
  end

  #start a new instance
  def start(workflow_definition, transition, document=nil)

    workflow_instance = WorkflowInstance.new

    #workflow_instance.document = document


    #convert from workflow_definition to persistent_workflow_definition
    persistent_workflow_definition = self.find_workflow_definition(workflow_definition.name, workflow_definition.version)
    workflow_instance.workflow_definition = persistent_workflow_definition
    workflow_instance.save!

    workflow_step = WorkflowStep.new
    workflow_step.workflow_instance = workflow_instance
    workflow_step.workflow_step_definition = persistent_workflow_definition.workflow_step_definitions[0]

    workflow_step.document = document
    workflow_step.save!

    transit(workflow_step, transition, document)
    #then take a transition step to persistent_workflow_definition.workflow_step_definitions[1]
  end

  def applicable_workflow_steps(user)
    if user =~ /manager1/
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ['workflow_step_definitions.participant_definition=?', 'manager1'])
    elsif user =~ /manager2/
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ['workflow_step_definitions.participant_definition=?', 'manager2'])
    else
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ['workflow_step_definitions.participant_definition=?', 'normal_employee'])
    end

    result
  end

  def find_workflow_definition(name, version)
    WorkflowDefinition.find(:first, :conditions => {:name=>name, :version=>version})
  end

  def transit(step, transition_name, document)
    
    transition = step.workflow_step_definition.workflow_transition_definitions.find(:all, :conditions=> ["name=?", transition_name])[0] #should only have one
    #should warn when transition is not found or more than one found?
    workflow_step = WorkflowStep.new
    workflow_step.workflow_instance_id = step.workflow_instance_id
    workflow_step.workflow_step_definition_id = transition.to_step_id
    workflow_step.document = document
    workflow_step.save!

    step.delete #move to history_step?
  end
end
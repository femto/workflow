require 'workflow/workflow_store'

class ActiveRecordWorkflowStore < AbstractWorkflowStore
  register(:activerecord_store, self)

#  class WorkflowDefinition < ActiveRecord::Base
#    has_many :workflow_instances
#  end

  def load_workflow_definition(workflow_definition)
    if find_workflow_definition(workflow_definition.name, workflow_definition.version)
      #logger.warn("already defined workflow_definition #{workflow_definition.name} v#{workflow_definition.version} in store")
      return
    end
    workflow_def = WorkflowDefinition.new
    workflow_def.name = workflow_definition.name
    workflow_def.version = workflow_definition.version
    workflow_def.document_cls = workflow_definition.document_cls

    workflow_def.save!

    workflow_definition.nodes.each do |node|
      workflow_step_definition = WorkflowStepDefinition.new
      workflow_step_definition.name = node.nodename
      workflow_step_definition.participant_definition = node.participant_definition
      workflow_step_definition.condition = node.condition
      workflow_step_definition.nodetype = node.nodetype

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

        #puts node.inspect
        #puts transition_definition.inspect
        transition_definition.to_step_id = transition.to.workflow_step_definition_id
        transition_definition.workflow_step_definition_id =  node.workflow_step_definition_id
        transition_definition.save!
      end
    end

  end

  #start a new instance
  def start(workflow_definition, transition_name, document=nil)
#    puts "ok"
#    puts  workflow_definition.name
#    puts transition
#    puts "starting #{workflow_definition.name} with #{transition}"
    workflow_instance = WorkflowInstance.new

    #workflow_instance.document = document


    #convert from workflow_definition to persistent_workflow_definition
    persistent_workflow_definition = self.find_workflow_definition(workflow_definition.name, workflow_definition.version)
    workflow_instance.workflow_definition = persistent_workflow_definition
    workflow_instance.workflow_name =  persistent_workflow_definition.name
    workflow_instance.save!

    workflow_step = WorkflowStep.new
    workflow_step.workflow_instance = workflow_instance

    workflow_step.workflow_step_definition = persistent_workflow_definition.workflow_step_definitions[0]

    workflow_step.document = document
    workflow_step.save!

    transit(workflow_step, transition_name, document)
    #then take a transition step to persistent_workflow_definition.workflow_step_definitions[1]
  end

  def applicable_workflow_steps(user)
    if user =~ /manager1/
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ["steptype <> 'join' and steptype <> 'end' and 'workflow_step_definitions.participant_definition=?", 'manager1'])
    elsif user =~ /manager2/
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ["steptype <> 'join' and steptype <> 'end' and 'workflow_step_definitions.participant_definition=?", 'manager2'])
    else
      result = WorkflowStep.find(:all, :include=> 'workflow_step_definition', :conditions=> ["steptype != 'join' and steptype != 'end' and workflow_step_definitions.participant_definition is null " +
              "or workflow_step_definitions.participant_definition=? or workflow_step_definitions.participant_definition=?", 'normal_employee', user])
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


    handle_incoming_workflow_step(workflow_step)


    step.delete #move to history_step?
  end

  def handle_incoming_workflow_step(workflow_step)
    #if workflow_step is special node, do we need to save it?

    if workflow_step.workflow_step_definition.nodetype == "fork"
      #p workflow_step.workflow_step_definition.workflow_transition_definitions
      # puts workflow_step.workflow_step_definition.workflow_transition_definitions.size
      workflow_step.workflow_step_definition.workflow_transition_definitions.each do |transition_definition|
        step = WorkflowStep.new

        step.workflow_instance_id = workflow_step.workflow_instance_id #inherit from it
        step.workflow_step_definition_id = transition_definition.to_step_id
        step.document = workflow_step.document #inherit from it
        handle_incoming_workflow_step(step)
      end
    elsif workflow_step.workflow_step_definition.nodetype == "join"

      #new_or_existing_join_step's' join_count+=1
      #if join_count reachs should_join_count

      #then transit next
      workflow_step.steptype = "join"
      workflow_step.save!
      #find out how much should join
      join_steps = WorkflowStep.find(:all, :conditions => ["workflow_instance_id = ? and workflow_step_definition_id = ? ", workflow_step.workflow_instance_id, workflow_step.workflow_step_definition_id])
      #p join_steps
      if join_count_condition_satisfied(workflow_step, join_steps.size)

        join_steps.map(&:delete)

        #puts join_steps[0].workflow_step_definition.workflow_transition_definitions.to_step_id
        step = WorkflowStep.new

        step.workflow_instance_id = workflow_step.workflow_instance_id
        step.workflow_step_definition_id = workflow_step.workflow_step_definition.workflow_transition_definitions[0].to_step_id
        step.document = workflow_step.document
        handle_incoming_workflow_step(step)
      end
    elsif workflow_step.workflow_step_definition.nodetype == "end"
      workflow_step.steptype = "end"
      workflow_step.save!
    else #normal workflow_step
      workflow_step.save!
    end

  end

  def join_count_condition_satisfied(workflow_step, size)
    join_count = workflow_step.workflow_step_definition.
            workflow_definition.workflow_step_definitions.
            count(:all, :include=>"workflow_transition_definitions",
                  :conditions=>["workflow_transition_definitions.to_step_id = ?", workflow_step.workflow_step_definition_id] )

    return size >= join_count 


  end

  def get_workflow_definitions(workflow_name)
    WorkflowDefinition.find(:first, :conditions => ["name = ?", workflow_name])
  end

  def can_start_workflow_definitions(user)
    WorkflowDefinition.find(:all, :include => 'workflow_step_definitions',
                            :conditions => ["workflow_step_definitions.nodetype = 'start' and ( workflow_step_definitions.participant_definition is null " +
                                    "or workflow_step_definitions.participant_definition = ?)", user])
  end

  def get_start_node(workflow_definition)
    workflow_definition.workflow_step_definitions.find(:first, :conditions => ["nodetype = 'start'"])
  end

#  def find_transitions(step_definition)
#
#  end

  def get_transitions(arg)
    if arg.is_a? WorkflowDefinition
      start_node =  get_start_node(arg)
      start_node.workflow_transition_definitions
      #elsif arg.is_a? WorkflowStep
      #else raise
    end

  end
end
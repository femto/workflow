load 'workflow/workflow_engine.rb'
load 'workflow/active_record_workflow_store.rb'

class WorkflowController < ApplicationController
#  def start
#
#    workflow_file = "#{RAILS_ROOT}/workflows/workflow_shouwen.workflow"
#    workflow_definition = global_workflow_engine.load_workflow_definition_if_not_exist(File.read(workflow_file))
#    render :text => File.read(workflow_file).gsub!("\n", "<br>")
#  end

  def start
    @workflow_name ||= params[:id]
    workflow_definition = global_engine.get_workflow_definitions(@workflow_name)
    #need we check the participant?
    #get associated document and render it
    document_cls = workflow_definition.document_cls
    if document_cls.is_a? String
      document = Object.const_get(document_cls).new

      @document = document

      @workflow_instance_id = "new"
      @transitions = global_engine.get_transitions(workflow_definition)

      #inline 
      render :inline => File.read("#{Rails.root}/workflow_views/#{@document.class.to_s.snake_case}.html.erb"), :layout=>'workflow'
    end
  end

  def run
    step_id = params[:id]
    @step = WorkflowStep.find_by_id(step_id)
    @document = @step.document
    render :file => "#{Rails.root}/workflow_views/#{@document.class.to_s.snake_case}", :layout=>'workflow_run'
  end

  def invoke
    
    workflow_name = params[:workflow_name]
    workflow_instance_id = params[:workflow_instance_id]
    engine = global_engine
    workflow_definition = engine.get_workflow_definitions(workflow_name)

    document_cls = workflow_definition.document_cls
    if workflow_instance_id == "new"

      begin
        if document_cls.is_a? String
          document = Object.const_get(document_cls).new(params[:document])
          document.save!
          #puts params[:workflow_transition]
          #puts document.class
          #puts workflow_definition.inspect
          workflow_definition.start(params[:workflow_transition], document)


        end
      rescue
        @workflow_name = workflow_name
        start

      end

    else


      if document_cls.is_a? String
        document = Object.const_get(document_cls).new
        document.amount = params[:amount].to_i
      end

      workflow_definition.next_step(params[:action])

    end

    "You have successfully #{params[:workflow_transition]} a workflow <br/>" +
            "<a href=/workspace>Back to workspace</a>"
  end
  def transit
    step = WorkflowStep.find(params[:workflow_step_id])
    step.document.update_attributes(params[:document])
    #step.document.amount.to_s
    global_engine.transit(step, params[:workflow_transition], step.document)
    "You have successfully #{params[:workflow_transition]} a workflow <br/>" +
            "<a href=/workspace>Back to workspace</a>"
  end
end

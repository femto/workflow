load 'workflow/workflow_engine.rb'
load 'workflow/active_record_workflow_store.rb'
class Admin::WorkflowController < ApplicationController

  def index
    #render :text=>AbstractWorkflowStore.stores.inspect

    global_workflow_engine.load_workflow_definition_file("#{Rails.root}/workflows/workflow_shouwen.workflow")
    @workflow_definitions = global_workflow_engine.workflow_definitions
  end
end

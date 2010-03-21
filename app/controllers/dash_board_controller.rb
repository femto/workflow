load 'workflow/workflow_engine.rb'
load 'workflow/active_record_workflow_store.rb'

class DashBoardController < ApplicationController
  def index
    @can_start_workflow_definitions = global_workflow_engine.can_start_workflow_definitions(current_user)

    #@running_workflow_instances = engine.running_workflow_instances(current_user)

    @applicable_workflow_steps = global_workflow_engine.applicable_workflow_steps(current_user)

  end
end

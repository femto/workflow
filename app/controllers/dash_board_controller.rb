class DashBoardController < ApplicationController
  def index
    @can_start_workflow_definitions = ["workflow_shouwen.workflow"]

    #@can_start_workflow_definitions = engine.can_start_workflow_definitions(current_user)

    #@running_workflow_instances = engine.running_workflow_instances(current_user)

    #@applicable_workflow_steps = engine.applicable_workflow_steps(current_user)

  end
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def current_user
    session[:current_user]
  end

  def global_workflow_engine
    $engine ||= WorkflowEngine.new(:store => :activerecord_store)
    #require 'simple_participant_resolvance'
  end
end

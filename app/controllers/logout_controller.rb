class LogoutController < ApplicationController
  def index
    session[:current_user] = nil
    render :text => 'logout succesfully'
  end
end

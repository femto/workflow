class LoginController < ApplicationController
  def index
    session[:current_user] = params[:id]
    render :text => 'login succesfully'
  end
end

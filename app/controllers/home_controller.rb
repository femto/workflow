class HomeController < ApplicationController
  def index
    redirect_to :controller => 'dash_board'
  end
end

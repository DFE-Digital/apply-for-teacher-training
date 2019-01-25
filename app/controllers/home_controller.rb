class HomeController < ApplicationController
  before_action :authenticate_candidate!, except: :index

  def index
  end
end

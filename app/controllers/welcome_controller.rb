class WelcomeController < ApplicationController
  before_action :authenticate_candidate!

  def show; end
end

class HomeController < ApplicationController
  before_action :authenticate_candidate!, except: %i[landing index]

  def landing
    redirect_to authenticated_root_path if current_candidate.present?
  end

  def index
    redirect_to unauthenticated_root_path unless current_candidate.present?
  end
end

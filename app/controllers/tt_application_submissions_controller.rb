require 'notifications/client'

class TTApplicationSubmissionsController < ApplicationController
  def create
    redirect_to(tt_application_path)
  end
end

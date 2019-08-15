require 'notifications/client'

class TTApplicationSubmissionsController < ApplicationController
  def create
    TTApplicationMailer.send_application(to: 'email@example.com').deliver!

    redirect_to(tt_application_path)
  end
end

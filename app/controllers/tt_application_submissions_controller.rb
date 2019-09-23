require 'notifications/client'

class TTApplicationSubmissionsController < ApplicationController
  before_action :authenticate_candidate!

  def create
    contact_details = ContactDetails.last
    TTApplicationMailer.send_application(to: ENV.fetch('DEFAULT_PROVIDER_EMAIL'), candidate_email: contact_details.email_address).deliver!

    redirect_to(tt_application_path)
  end
end

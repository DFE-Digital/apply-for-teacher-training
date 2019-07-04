class TTApplicationsController < ApplicationController
  def show
    @personal_details = PersonalDetails.last
  end
end

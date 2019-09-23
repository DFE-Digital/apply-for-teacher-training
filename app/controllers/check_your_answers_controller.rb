class CheckYourAnswersController < ApplicationController
  before_action :authenticate_candidate!

  def show
    @application = {
      personal_details: PersonalDetails.last,
      contact_details: ContactDetails.last,
      degrees: Degree.all,
      qualifications: Qualification.all
    }
  end
end

class CheckYourAnswersController < ApplicationController
  def show
    @application = {
      personal_details: PersonalDetails.last,
      contact_details: ContactDetails.last,
      degrees: Degree.all
    }
  end
end

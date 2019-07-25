class CheckYourAnswersController < ApplicationController
  def show
    @personal_details = PersonalDetails.last
    @contact_details = ContactDetails.last
    @degree = Degree.last
  end
end

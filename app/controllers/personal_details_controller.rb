class PersonalDetailsController < ApplicationController
  def new
    @personal_details = PersonalDetails.new
  end
end

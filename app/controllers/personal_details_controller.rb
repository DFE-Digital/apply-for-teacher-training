class PersonalDetailsController < ApplicationController
  def new
    @personal_details = PersonalDetails.new
  end

  def create
    @personal_details = PersonalDetails.new(personal_details_params)
  end

private

  def personal_details_params
    params.require(:personal_details).permit(:title)
  end
end

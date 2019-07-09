class PersonalDetailsController < ApplicationController
  def new
    @personal_details = PersonalDetails.new
  end

  def create
    @personal_details = PersonalDetails.new(personal_details_params)
    @personal_details.save

    redirect_to check_your_answers_path
  end

private

  def personal_details_params
    params.require(:personal_details).permit(:title,
                                             :first_name,
                                             :last_name,
                                             :preferred_name,
                                             :date_of_birth,
                                             :nationality)
  end
end

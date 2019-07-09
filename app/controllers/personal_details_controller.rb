class PersonalDetailsController < ApplicationController
  def new
    @personal_details = if params[:reviewing]
                          PersonalDetails.last
                        else
                          PersonalDetails.new
                        end
  end

  def create
    @personal_details = PersonalDetails.new(personal_details_params)
    @personal_details.save

    redirect_to check_your_answers_path
  end

  def update
    @personal_details = PersonalDetails.last
    @personal_details.update(personal_details_params)

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

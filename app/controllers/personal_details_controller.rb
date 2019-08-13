class PersonalDetailsController < ApplicationController
  before_action :require_candidate!

  def new
    puts 'current_candidate >>>>>> '
    puts current_candidate.inspect
    @personal_details = PersonalDetails.new
  end

  def edit
    @personal_details = PersonalDetails.find(params[:id])
  end

  def create
    @personal_details = PersonalDetails.new(personal_details_params)

    if @personal_details.save
      redirect_to new_contact_details_path
    else
      render :new
    end
  end

  def update
    @personal_details = PersonalDetails.find(params[:id])

    if @personal_details.update(personal_details_params)
      redirect_to check_your_answers_path
    else
      render :new
    end
  end

private

  def personal_details_params
    params.require(:personal_details).permit(:title,
                                             :first_name,
                                             :last_name,
                                             :preferred_name,
                                             :date_of_birth)
  end
end

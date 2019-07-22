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

    if @personal_details.save
      if @personal_details.nationality == 'British'
        redirect_to contact_details_path
      else
        redirect_to new_residency_status_path
      end
    else
      render :new
    end
  end

  def update
    @personal_details = PersonalDetails.last

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
                                             :date_of_birth,
                                             :nationality)
  end
end

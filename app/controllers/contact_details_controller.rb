class ContactDetailsController < ApplicationController
  def new
    @personal_details = PersonalDetails.last
  end

  def update
    @personal_details = PersonalDetails.last

    if @personal_details.update(contact_details_params)
      redirect_to check_your_answers_path
    else
      render :new
    end
  end

  def create
    PersonalDetails.last.update(contact_details_params)

    redirect_to check_your_answers_path
  end

private

  def contact_details_params
    params.require(:personal_details).permit(:phone_number, :email_address, :address)
  end
end

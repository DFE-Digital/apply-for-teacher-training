class ContactDetailsController < ApplicationController
  def new
    @contact_details = ContactDetails.new
  end

  def update
    @contact_details = ContactDetails.find(params[:id])

    if @contact_details.update(contact_details_params)
      redirect_to check_your_answers_path
    else
      render :new
    end
  end

  def edit
    @contact_details = ContactDetails.find(params[:id])
  end

  def create
    @contact_details = ContactDetails.create(contact_details_params)

    redirect_to check_your_answers_path
  end

private

  def contact_details_params
    params.require(:contact_details).permit(:phone_number, :email_address, :address)
  end
end

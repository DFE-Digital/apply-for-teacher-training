class AlreadyCarriedOverFilter < ApplicationFilter
  delegate :candidate_interface_application_choices_path,
           to: :controller

  def call
    return if current_application.carry_over?

    redirect_to candidate_interface_application_choices_path
  end
end

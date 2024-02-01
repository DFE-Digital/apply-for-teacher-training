class AlreadyCarriedOverFilter < ApplicationFilter
  delegate :candidate_interface_continuous_applications_details_path,
           :candidate_interface_start_carry_over_path,
           to: :controller

  def call
    return if current_application.carry_over?

    redirect_to candidate_interface_continuous_applications_details_path if current_application.continuous_applications?
  end
end

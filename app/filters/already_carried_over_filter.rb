class AlreadyCarriedOverFilter < ApplicationFilter
  delegate :candidate_interface_details_path,
           :candidate_interface_start_carry_over_path,
           to: :controller

  def call
    return if current_application.carry_over?

    redirect_to candidate_interface_details_path
  end
end

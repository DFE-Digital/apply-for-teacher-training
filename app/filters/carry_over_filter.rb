class CarryOverFilter < ApplicationFilter
  delegate :candidate_interface_start_carry_over_path, :params, to: :controller

  def call
    return unless current_application.carry_over?

    redirect_to candidate_interface_start_carry_over_path(current_tab_name: params[:current_tab_name])
  end
end

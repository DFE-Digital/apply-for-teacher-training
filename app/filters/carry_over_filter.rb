class CarryOverFilter < ApplicationFilter
  delegate :candidate_interface_application_choices_path, :params, to: :controller

  def call
    return unless current_application.carry_over?

    redirect_to candidate_interface_application_choices_path(current_tab_name: params[:current_tab_name])
  end
end

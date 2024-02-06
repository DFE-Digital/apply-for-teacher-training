class UnsuccessfulCarryOverFilter < ApplicationFilter
  delegate :candidate_interface_application_complete_path, to: :controller

  def call
    return if CycleTimetable.can_add_course_choice?(current_application) || current_application.carry_over?

    redirect_to candidate_interface_application_complete_path unless current_application.continuous_applications?
  end
end

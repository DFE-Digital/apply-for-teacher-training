class UnsuccessfulCarryOverFilter < ApplicationFilter
  delegate :candidate_interface_application_complete_path, to: :controller

  def call
    return unless current_application.carry_over?
    return if CycleTimetable.can_add_course_choice?(current_application)

    redirect_to candidate_interface_application_complete_path
  end
end

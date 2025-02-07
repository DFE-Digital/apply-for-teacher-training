class UnsuccessfulCarryOverFilter < ApplicationFilter
  delegate :candidate_interface_start_carry_over_path, to: :controller

  def call
    return if CycleTimetable.can_add_course_choice?(current_application) || current_application.carry_over?

    redirect_to candidate_interface_start_carry_over_path if current_application.v23?
  end
end

class UnsuccessfulCarryOverFilter < ApplicationFilter
  delegate :candidate_interface_application_choices_path, to: :controller

  def call
    return if current_application.can_add_course_choice? || current_application.carry_over?

    redirect_to candidate_interface_application_choices_path if current_application.v23?
  end
end

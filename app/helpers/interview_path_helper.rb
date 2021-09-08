module InterviewPathHelper
  def interview_path_for(application_choice, wizard, interview, step, params = {})
    if step.to_sym == :referer
      wizard.referer
    elsif step.to_sym == :input
      new_provider_interface_application_choice_interview_path(application_choice, params)
    elsif step.to_sym == :edit
      edit_provider_interface_application_choice_interview_path(application_choice, interview, params)
    elsif step.to_sym == :check
      if interview
        edit_provider_interface_application_choice_interview_check_path(application_choice, interview, params)
      else
        new_provider_interface_interviews_check_path(application_choice, params)
      end
    end
  end
end

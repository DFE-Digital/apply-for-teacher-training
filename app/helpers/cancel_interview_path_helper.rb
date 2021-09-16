module CancelInterviewPathHelper
  def cancel_interview_path_for(application_choice, wizard, interview, step, params = {})
    if step.to_sym == :referer
      wizard.referer
    elsif step.to_sym == :new
      new_provider_interface_application_choice_interview_cancel_path(application_choice, params)
    elsif step.to_sym == :check
      provider_interface_application_choice_interview_cancel_path(application_choice, interview, params)
    end
  end
end

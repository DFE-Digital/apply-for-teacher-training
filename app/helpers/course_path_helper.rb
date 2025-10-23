module CoursePathHelper
  def course_path_for(application_choice, step, params = {})
    if step.to_sym.in?(%i[select_option referer]) && application_choice.pending_conditions?
      provider_interface_application_choice_offer_path(application_choice)
    elsif step.to_sym.in?(%i[select_option referer])
      provider_interface_application_choice_path(application_choice, params)
    else
      [:edit, :provider_interface, application_choice, :course, step, params]
    end
  end
end

module CoursePathHelper
  def course_path_for(application_choice, step, params = {})
    if step.to_sym == :select_option
      provider_interface_application_choice_path(application_choice, params)
    else
      [:edit, :provider_interface, application_choice, :course, step, params]
    end
  end
end

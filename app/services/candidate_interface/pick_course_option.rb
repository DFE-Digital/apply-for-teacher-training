module CandidateInterface
  class PickCourseOption
    attr_reader :course_id, :course_option_id, :application_form, :provider_id, :controller

    def initialize(course_id, course_option_id, application_form, provider_id, controller)
      @course_id = course_id
      @course_option_id = course_option_id
      @application_form = application_form
      @provider_id = provider_id
      @controller = controller
    end

    delegate(
      :flash,
      :redirect_to,
      :candidate_interface_course_choices_add_another_course_path,
      :candidate_interface_course_choices_index_path,
      to: :controller,
    )

    def call
      pick_site_form = PickSiteForm.new(
        application_form: application_form,
        provider_id: provider_id,
        course_id: course_id,
        course_option_id: course_option_id,
      )

      if pick_site_form.save
        application_form.update!(course_choices_completed: false)
        course_choices = application_form.application_choices
        flash[:success] = "You’ve added #{course_choices.last.course.name_and_code} to your application"

        if application_form.can_add_more_choices?
          redirect_to candidate_interface_course_choices_add_another_course_path
        else
          redirect_to candidate_interface_course_choices_index_path
        end
      else
        flash[:warning] = pick_site_form.errors.full_messages.first
        redirect_to candidate_interface_application_form_path
      end
    end
  end
end

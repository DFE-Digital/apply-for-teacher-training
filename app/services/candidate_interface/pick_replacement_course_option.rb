module CandidateInterface
  class PickReplacementCourseOption
    attr_reader :course_id, :course_option_id, :application_form, :provider_id, :controller, :old_course_option_id

    def initialize(course_id, course_option_id, application_form, provider_id, controller, old_course_option_id:)
      @course_id = course_id
      @course_option_id = course_option_id
      @application_form = application_form
      @provider_id = provider_id
      @controller = controller
      @old_course_option_id = old_course_option_id
    end

    delegate(
      :params,
      :flash,
      :redirect_to,
      :candidate_interface_course_choices_index_path,
      to: :controller,
    )

    def call
      old_application_choice = application_form.application_choices.find(old_course_option_id)

      pick_site_form = PickSiteForm.new(
        application_form: application_form,
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        course_option_id: course_option_id,
      )

      pick_site_form.update(old_application_choice)

      unless pick_site_form.valid?
        flash[:warning] = pick_site_form.errors.full_messages.first
      end

      redirect_to candidate_interface_course_choices_index_path
    end
  end
end

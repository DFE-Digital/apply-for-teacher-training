module CandidateInterface
  class AddOrUpdateCourseChoice
    attr_reader :course_id, :course_option_id, :application_form, :provider_id, :controller, :id_of_course_choice_to_replace

    def initialize(course_id, course_option_id, application_form, provider_id, controller, id_of_course_choice_to_replace: nil)
      @course_id = course_id
      @course_option_id = course_option_id
      @application_form = application_form
      @provider_id = provider_id
      @controller = controller
      @id_of_course_choice_to_replace = id_of_course_choice_to_replace
    end

    delegate(
      :flash,
      :redirect_to,
      :candidate_interface_course_choices_add_another_course_path,
      :candidate_interface_course_choices_index_path,
      :candidate_interface_application_form_path,
      to: :controller,
    )

    def call
      if id_of_course_choice_to_replace
        add_replacement and return
      end

      if existing_choice_with_matching_course
        @id_of_course_choice_to_replace = existing_choice_with_matching_course.id
        add_replacement and return
      end

      add
    end

  private

    def course
      @course ||= Provider.find(provider_id).courses.find(course_id)
    end

    def application_choices
      @application_choices ||= application_form.application_choices.includes(:course)
    end

    def existing_choice_with_matching_course
      application_choices.find { |choice| choice.course == course }
    end

    def add
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
        redirect_to candidate_interface_course_choices_index_path
      end
    end

    def add_replacement
      old_application_choice = application_form.application_choices.find(id_of_course_choice_to_replace)

      pick_site_form = PickSiteForm.new(
        application_form: application_form,
        provider_id: provider_id,
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

module CandidateInterface
  class AddOrUpdateCourseChoice
    attr_reader :course_option_id, :application_form, :controller, :id_of_course_choice_to_replace

    def initialize(course_option_id:, application_form:, controller:, return_to: nil, id_of_course_choice_to_replace: nil)
      @course_option_id = course_option_id
      @application_form = application_form
      @controller = controller
      @id_of_course_choice_to_replace = id_of_course_choice_to_replace
      @return_to = return_to
    end

    delegate(
      :flash,
      :redirect_to,
      :candidate_interface_course_choices_choose_path,
      :candidate_interface_application_form_path,
      :candidate_interface_course_choices_review_path,
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

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
    end

    def course
      @course ||= course_option.course
    end

    def application_choices
      @application_choices ||= application_form.application_choices.includes(:course)
    end

    def existing_choice_with_matching_course
      application_choices.find { |choice| choice.course == course }
    end

    def add
      pick_site_form = PickSiteForm.new(
        application_form:,
        course_option_id:,
      )

      if pick_site_form.save
        redirect_to candidate_interface_course_choices_review_path
      else
        flash[:warning] = pick_site_form.errors.full_messages.first

        if application_form.application_choices.any?
          redirect_to candidate_interface_course_choices_review_path
        else
          redirect_to candidate_interface_course_choices_choose_path
        end
      end
    end

    def add_replacement
      old_application_choice = application_form.application_choices.find(id_of_course_choice_to_replace)

      pick_site_form = PickSiteForm.new(
        application_form:,
        course_option_id:,
      )

      pick_site_form.update(old_application_choice)

      unless pick_site_form.valid?
        flash[:warning] = pick_site_form.errors.full_messages.first
      end

      if @return_to == 'application-review'
        redirect_to '/candidate/application/review'
      else
        redirect_to candidate_interface_course_choices_review_path
      end
    end
  end
end

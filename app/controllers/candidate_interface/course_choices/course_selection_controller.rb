module CandidateInterface
  module CourseChoices
    class CourseSelectionController < BaseController
      before_action { redirect_to_continuous_applications(action_name) }

      def new
        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          application_form: current_application,
        )
      end

      def edit
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)
        @return_to = return_to_after_edit(default: candidate_interface_course_choices_review_path)

        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          application_form: current_application,
          course_id: current_application_choice.course.id,
        )
      end

      def create
        course_id = params.dig(:candidate_interface_pick_course_form, :course_id)

        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          course_id:,
          application_form: current_application,
        )
        render :new and return unless @pick_course.valid?

        redirect_to_review_page_if_course_already_added(current_application, course_id)
        return if performed?

        if !@pick_course.available?
          redirect_to candidate_interface_course_choices_full_path(
            @pick_course.provider_id,
            @pick_course.course_id,
          )
        elsif @pick_course.currently_has_both_study_modes_available?
          redirect_to candidate_interface_course_choices_study_mode_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            course_choice_id: params[:course_choice_id],
          )
        elsif @pick_course.single_site?
          course_option = @pick_course.available_course_options.first
          AddOrUpdateCourseChoice.new(
            course_option_id: course_option.id,
            application_form: current_application,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          ).call
        else
          redirect_to candidate_interface_course_choices_site_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            @pick_course.available_study_modes_with_vacancies.first,
            course_choice_id: params[:course_choice_id],
          )
        end
      end

      def update
        course_id = params.dig(:candidate_interface_pick_course_form, :course_id)

        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          course_id:,
          application_form: current_application,
        )
        render :new and return unless @pick_course.valid?

        redirect_to_review_page_if_course_already_added(current_application, course_id)
        return if performed?

        if !@pick_course.available?
          redirect_to candidate_interface_course_choices_full_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            return_to: params[:return_to],
            previous_course_choice_id: params[:course_choice_id],
          )
        elsif @pick_course.currently_has_both_study_modes_available?
          redirect_to candidate_interface_edit_course_choices_study_mode_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            course_choice_id: params[:course_choice_id],
            return_to: params[:return_to],
          )
        elsif @pick_course.single_site?
          course_option = @pick_course.available_course_options.first
          AddOrUpdateCourseChoice.new(
            course_option_id: course_option.id,
            application_form: current_application,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          ).call
        else
          redirect_to candidate_interface_edit_course_choices_site_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            @pick_course.available_study_modes_with_vacancies.first,
            course_choice_id: params[:course_choice_id],
            return_to: params[:return_to],
          )
        end
      end

      def full
        @course = Course.find(params[:course_id])

        @return_to_path = if params[:return_to].nil?
                            candidate_interface_course_choices_course_path(@course.provider)
                          else
                            candidate_interface_edit_course_choices_course_path(
                              course_choice_id: params[:previous_course_choice_id],
                              return_to: params[:return_to],
                            )
                          end
      end

    private

      def redirect_to_review_page_if_course_already_added(application_form, course_id)
        course = Course.find(course_id)

        if application_form.contains_course? course
          flash[:info] = I18n.t!('errors.application_choices.already_added', course_name_and_code: course.name_and_code)
          redirect_to candidate_interface_course_choices_review_path
        end
      end

      def redirect_to_continuous_applications(action)
        case action
        when /new/
          redirect_to candidate_interface_continuous_applications_which_course_are_you_applying_to_path(params['provider_id'])
        end
      end
    end
  end
end

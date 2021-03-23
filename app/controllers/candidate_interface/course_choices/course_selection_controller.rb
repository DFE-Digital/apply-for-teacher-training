module CandidateInterface
  module CourseChoices
    class CourseSelectionController < BaseController
      def new
        if params[:course_choice_id]
          @course_choice_id = params[:course_choice_id]
          current_application_choice = current_application.application_choices.find(@course_choice_id)

          @pick_course = PickCourseForm.new(
            provider_id: params.fetch(:provider_id),
            application_form: current_application,
            course_id: current_application_choice.course.id,
          )
        else
          @pick_course = PickCourseForm.new(
            provider_id: params.fetch(:provider_id),
            application_form: current_application,
          )
        end
      end

      def create
        course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: course_id,
          application_form: current_application,
        )
        redirect_to_review_page_with_already_added_message and return if @pick_course.already_picked_this_one?
        render :new and return unless @pick_course.valid?

        if !@pick_course.open_on_apply?
          redirect_to candidate_interface_course_choices_ucas_with_course_path(@pick_course.provider_id, @pick_course.course_id)
        elsif !@pick_course.available?
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
          course_option = CourseOption.where(course_id: @pick_course.course.id).first
          PickCourseOption.new(
            course_id,
            course_option.id,
            current_application,
            params.fetch(:provider_id),
            self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          ).call
        else
          redirect_to candidate_interface_course_choices_site_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            @pick_course.study_mode,
            course_choice_id: params[:course_choice_id],
          )
        end
      end

      def full
        @course = Course.find(params[:course_id])
      end

    private

      def redirect_to_review_page_with_already_added_message
        flash[:info] = @pick_course.already_added_error
        redirect_to candidate_interface_course_choices_review_path
      end
    end
  end
end

module CandidateInterface
  module CourseChoices
    class CourseSelectionController < BaseController
      def options_for_course
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

      def pick_course
        course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
        @pick_course = PickCourseForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: course_id,
          application_form: current_application,
        )
        render :options_for_course and return unless @pick_course.valid?

        if !@pick_course.open_on_apply?
          redirect_to candidate_interface_course_choices_ucas_with_course_path(@pick_course.provider_id, @pick_course.course_id)
        elsif @pick_course.full?
          redirect_to candidate_interface_course_choices_full_path(
            @pick_course.provider_id,
            @pick_course.course_id,
          )
        elsif @pick_course.both_study_modes_available?
          redirect_to candidate_interface_course_choices_study_mode_path(
            @pick_course.provider_id,
            @pick_course.course_id,
            course_choice_id: params[:course_choice_id],
          )
        elsif @pick_course.single_site?
          course_option = CourseOption.where(course_id: @pick_course.course.id).first
          if params[:course_choice_id]
            PickReplacementCourseOption.new(
              course_id,
              course_option.id,
              current_application,
              params.fetch(:provider_id),
              self,
              old_course_option_id: params[:course_choice_id],
            ).call
          else
            PickCourseOption.new(
              course_id,
              course_option.id,
              current_application,
              params.fetch(:provider_id),
              self,
            ).call
          end
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
    end
  end
end

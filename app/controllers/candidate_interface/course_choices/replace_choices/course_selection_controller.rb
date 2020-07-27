module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class CourseSelectionController < BaseController
        def new
          @course_choice = current_application.application_choices.find(params['id'])
          @provider = Provider.find(params['provider_id'])
          @pick_course = PickCourseForm.new(
            provider_id: params.fetch(:provider_id),
            application_form: current_application,
          )
        end

        def create
          @course_choice = current_application.application_choices.find(params['id'])
          @provider = Provider.find(params['provider_id'])
          course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
          @pick_course = PickCourseForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: course_id,
            application_form: current_application,
          )
          render :new and return unless @pick_course.valid?

          if !@pick_course.open_on_apply?
            redirect_to candidate_interface_replace_course_choice_ucas_with_course_path(
              @course_choice.id,
              @pick_course.provider_id,
              @pick_course.course_id,
            )
          elsif @pick_course.full?
            redirect_to candidate_interface_replace_course_choice_full_path(
              @course_choice.id,
              @pick_course.provider_id,
              @pick_course.course_id,
            )
          elsif @pick_course.both_study_modes_available?
            redirect_to candidate_interface_replace_course_choice_study_mode_path(
              @course_choice.id,
              @pick_course.provider_id,
              @pick_course.course_id,
            )
          elsif @pick_course.single_site?
            @replacement_course_option_id = CourseOption.find_by(
              course_id: course_id,
            )

            redirect_to candidate_interface_confirm_replacement_course_choice_path(
              @course_choice.id,
              @replacement_course_option_id,
              provider_id: params['provider_id'],
              course_id: params['course_id'],
            )
          else
            redirect_to candidate_interface_replace_course_choice_location_path(
              @course_choice.id,
              @pick_course.provider_id,
              @pick_course.course_id,
              @pick_course.study_mode,
            )
          end
        end

        def full
          @course_choice = current_application.application_choices.find(params['id'])
          @course = Course.find(params[:course_id])
        end
      end
    end
  end
end

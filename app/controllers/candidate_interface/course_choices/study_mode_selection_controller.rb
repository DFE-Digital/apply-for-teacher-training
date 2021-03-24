module CandidateInterface
  module CourseChoices
    class StudyModeSelectionController < BaseController
      def new
        if params[:course_choice_id]
          @course_choice_id = params[:course_choice_id]
          current_application_choice = current_application.application_choices.find(@course_choice_id)

          @pick_study_mode = PickStudyModeForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: params.fetch(:course_id),
            study_mode: current_application_choice.offered_option.study_mode,
          )
        else
          @pick_study_mode = PickStudyModeForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: params.fetch(:course_id),
          )
        end
      end

      def create
        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: params.dig(
            :candidate_interface_pick_study_mode_form,
            :study_mode,
          ),
        )
        render :new and return unless @pick_study_mode.valid?

        if @pick_study_mode.single_site_course?
          AddOrUpdateCourseChoice.new(
            @pick_study_mode.first_site_id,
            current_application,
            self,
            id_of_course_choice_to_replace: params[:course_choice_id],
          ).call
        else
          redirect_to candidate_interface_course_choices_site_path(
            @pick_study_mode.provider_id,
            @pick_study_mode.course_id,
            @pick_study_mode.study_mode,
            course_choice_id: params[:course_choice_id],
          )
        end
      end
    end
  end
end

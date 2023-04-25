module CandidateInterface
  module CourseChoices
    class StudyModeSelectionController < BaseController
      def new
        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
        )
      end

      def edit
        @course_choice_id = params[:course_choice_id]
        current_application_choice = current_application.application_choices.find(@course_choice_id)
        @return_to = return_to_after_edit(default: candidate_interface_course_choices_review_path)

        @application_review = params['return-to'] || params[:return_to]

        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: current_application_choice.current_course_option.study_mode,
        )
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
          redirect_to candidate_interface_course_choices_personal_statement_path(
            @pick_study_mode.provider_id,
            @pick_study_mode.course_id,
            @pick_study_mode.study_mode,
            course_choice_id: params[:course_choice_id],
          )
        else
          redirect_to candidate_interface_course_choices_site_path(
            @pick_study_mode.provider_id,
            @pick_study_mode.course_id,
            @pick_study_mode.study_mode,
            course_choice_id: params[:course_choice_id],
          )
        end
      end

      def update
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
            course_option_id: @pick_study_mode.first_site_id,
            application_form: current_application,
            controller: self,
            id_of_course_choice_to_replace: params[:course_choice_id],
            return_to: params[:return_to],
          ).call
        else
          redirect_to candidate_interface_edit_course_choices_site_path(
            @pick_study_mode.provider_id,
            @pick_study_mode.course_id,
            @pick_study_mode.study_mode,
            course_choice_id: params[:course_choice_id],
            return_to: params[:return_to],
          )
        end
      end
    end
  end
end

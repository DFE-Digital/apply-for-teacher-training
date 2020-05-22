module CandidateInterface
  module CourseChoices
    class StudyModeSelectionController < BaseController
      def options_for_study_mode
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

      def pick_study_mode
        @pick_study_mode = PickStudyModeForm.new(
          provider_id: params.fetch(:provider_id),
          course_id: params.fetch(:course_id),
          study_mode: params.dig(
            :candidate_interface_pick_study_mode_form,
            :study_mode,
          ),
        )
        render :options_for_study_mode and return unless @pick_study_mode.valid?

        if @pick_study_mode.single_site_course?
          if params[:course_choice_id]
            pick_new_site_for_course(
              @pick_study_mode.course_id,
              @pick_study_mode.first_site_id,
            )
          else
            pick_site_for_course(
              @pick_study_mode.course_id,
              @pick_study_mode.first_site_id,
            )
          end
        else
          redirect_to candidate_interface_course_choices_site_path(
            @pick_study_mode.provider_id,
            @pick_study_mode.course_id,
            @pick_study_mode.study_mode,
            course_choice_id: params[:course_choice_id],
          )
        end
      end

    private

      def pick_site_for_course(course_id, course_option_id)
        @pick_site = PickSiteForm.new(
          application_form: current_application,
          provider_id: params.fetch(:provider_id),
          course_id: course_id,
          course_option_id: course_option_id,
        )

        if @pick_site.save
          current_application.update!(course_choices_completed: false)
          @course_choices = current_candidate.current_application.application_choices
          flash[:success] = "You’ve added #{@course_choices.last.course.name_and_code} to your application"

          if @course_choices.count.between?(1, 2) && !current_application.apply_again?
            redirect_to candidate_interface_course_choices_add_another_course_path
          else
            redirect_to candidate_interface_course_choices_index_path
          end

        else
          flash[:warning] = @pick_site.errors.full_messages.first
          redirect_to candidate_interface_application_form_path
        end
      end

      def pick_new_site_for_course(course_id, course_option_id)
        @course_choice_id = params[:course_choice_id]
        application_choice = current_application.application_choices.find(params[:course_choice_id])

        @pick_site = PickSiteForm.new(
          application_form: current_application,
          provider_id: params.fetch(:provider_id),
          course_id: course_id,
          course_option_id: course_option_id,
        )

        if @pick_site.update(application_choice)
          redirect_to candidate_interface_course_choices_index_path
        else
          render :options_for_site
        end
      end
    end
  end
end

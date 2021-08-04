module CandidateInterface
  module PersonalDetails
    class RightToWorkOrStudyController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @right_to_work_or_study_form = RightToWorkOrStudyForm.build_from_application(current_application)
      end

      def create
        @right_to_work_or_study_form = RightToWorkOrStudyForm.new(right_to_work_params)

        if @right_to_work_or_study_form.save(current_application)
          if LanguagesSectionPolicy.hide?(current_application)
            redirect_to candidate_interface_personal_details_show_path
          else
            redirect_to candidate_interface_languages_path
          end
        else
          track_validation_error(@right_to_work_or_study_form)
          render :new
        end
      end

      def edit
        @right_to_work_or_study_form = RightToWorkOrStudyForm.build_from_application(current_application)
        @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)
      end

      def update
        @right_to_work_or_study_form = RightToWorkOrStudyForm.new(right_to_work_params)
        @return_to = return_to_after_edit(default: candidate_interface_personal_details_complete_path)

        if @right_to_work_or_study_form.save(current_application)
          return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?

          redirect_to candidate_interface_personal_details_show_path
        else
          track_validation_error(@right_to_work_or_study_form)
          render :edit
        end
      end

    private

      def right_to_work_params
        strip_whitespace params.require(:candidate_interface_right_to_work_or_study_form).permit(
          :right_to_work_or_study, :right_to_work_or_study_details
        )
      end
    end
  end
end

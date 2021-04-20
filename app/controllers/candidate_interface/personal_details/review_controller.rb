module CandidateInterface
  module PersonalDetails
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def show
        @application_form = current_application
        @section_complete_form = SectionCompleteForm.new(
          completed: current_application.personal_details_completed,
        )
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @languages_form = LanguagesForm.build_from_application(current_application)
        @personal_details_review = PersonalDetailsReviewComponent.new(
          application_form: current_application,
        )
      end

      def complete
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @languages_form = LanguagesForm.build_from_application(current_application)
        @right_to_work_or_study_form = RightToWorkOrStudyForm.build_from_application(current_application)
        @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])
        @personal_details_review = PersonalDetailsReviewComponent.new(application_form: current_application)

        if all_sections_valid? || hiding_languages?
          save_section_complete_form
        else
          render :show
        end
      end

    private

      def all_sections_valid?
        @personal_details_form.valid? && @nationalities_form.valid? && @right_to_work_or_study_form.valid? && @languages_form.valid?
      end

      def hiding_languages?
        @personal_details_form.valid? && @nationalities_form.valid? && (hiding_languages_section? || @languages_form.valid?)
      end

      def save_section_complete_form
        if @section_complete_form.save(current_application, :personal_details_completed)
          redirect_to candidate_interface_application_form_path
        else
          track_validation_error(@section_complete_form)
          render :show
        end
      end

      def application_form_params
        strip_whitespace params.require(:candidate_interface_section_complete_form).permit(:completed)
      end

      def hiding_languages_section?
        LanguagesSectionPolicy.hide?(current_application)
      end
    end
  end
end

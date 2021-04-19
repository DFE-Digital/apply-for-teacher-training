module CandidateInterface
  module PersonalDetails
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def show
        @application_form = current_application
        @completion_form = CompletionForm.build_from_application(
          personal_details_completed: current_application.personal_details_completed,
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
        @completion_form = CompletionForm.build_from_application(application_form_params)
        @personal_details_review = PersonalDetailsReviewComponent.new(application_form: current_application)

        if @personal_details_form.valid? && @nationalities_form.valid? && @right_to_work_or_study_form.valid? && @languages_form.valid?
          save_completion_form
        elsif @personal_details_form.valid? && @nationalities_form.valid? && (hiding_languages_section? || @languages_form.valid?)
          save_completion_form
        else
          render :show
        end
      end

    private

      def save_completion_form
        if @completion_form.save(current_application, :personal_details_completed)
          redirect_to candidate_interface_application_form_path
        else
          track_validation_error(@completion_form)
          render :show
        end
      end

      def application_form_params
        strip_whitespace params.require(:candidate_interface_completion_form).permit(:personal_details_completed)
      end

      def hiding_languages_section?
        LanguagesSectionPolicy.hide?(current_application)
      end
    end
  end
end

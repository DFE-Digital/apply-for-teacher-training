module CandidateInterface
  module PersonalDetails
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def show
        @application_form = current_application
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

        if FeatureFlag.active?('international_personal_details') &&
            @personal_details_form.valid? &&
            @nationalities_form.valid? &&
            @right_to_work_or_study_form.valid?

          current_application.update!(application_form_params)

          redirect_to candidate_interface_application_form_path
        elsif @personal_details_form.valid? &&
            @nationalities_form.valid? &&
            (hiding_languages_section? || @languages_form.valid?)

          current_application.update!(application_form_params)

          redirect_to candidate_interface_application_form_path
        else
          render :show
        end
      end

    private

      def application_form_params
        params.require(:application_form).permit(:personal_details_completed)
          .transform_values(&:strip)
      end

      def hiding_languages_section?
        LanguagesSectionPolicy.hide?(current_application)
      end
    end
  end
end

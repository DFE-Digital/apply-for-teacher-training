module CandidateInterface
  module PersonalDetails
    class ReviewController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def show
        @application_form = current_application
        @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
        @nationalities_form = NationalitiesForm.build_from_application(current_application)
        @languages_form = LanguagesForm.build_from_application(current_application)
        @personal_details_review = PersonalDetailsReviewPresenter.new(
          personal_details_form: @personal_details_form,
          nationalities_form: @nationalities_form,
          languages_form: @languages_form,
        )
      end

      def complete
        if PersonalDetailsForm.build_from_application(current_application).valid? &&
            NationalitiesForm.build_from_application(current_application).valid? &&
            LanguagesForm.build_from_application(current_application).valid?

          current_application.update!(application_form_params)

          redirect_to candidate_interface_application_form_path
        else
          @personal_details_form = PersonalDetailsForm.build_from_application(current_application)
          @nationalities_form = NationalitiesForm.build_from_application(current_application)
          @languages_form = LanguagesForm.build_from_application(current_application)

          render :show
        end
      end

    private

      def application_form_params
        params.require(:application_form).permit(:personal_details_completed)
          .transform_values(&:strip)
      end
    end
  end
end

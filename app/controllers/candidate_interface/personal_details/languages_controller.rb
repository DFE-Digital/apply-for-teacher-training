module CandidateInterface
  module PersonalDetails
    class LanguagesController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @languages_form = LanguagesForm.new
      end

      def create
        @application_form = current_application
        @languages_form = LanguagesForm.new(languages_params)

        if @languages_form.save(current_application)
          redirect_to candidate_interface_personal_details_show_path
        else
          track_validation_error(@languages_form)
          render :new
        end
      end

      def edit
        @languages_form = LanguagesForm.build_from_application(current_application)
      end

      def update
        @application_form = current_application
        @languages_form = LanguagesForm.new(languages_params)

        if @languages_form.save(current_application)
          redirect_to candidate_interface_personal_details_show_path
        else
          track_validation_error(@languages_form)
          render :edit
        end
      end

    private

      def languages_params
        strip_whitespace params
          .require(:candidate_interface_languages_form)
          .permit(:english_main_language, :english_language_details, :other_language_details)
      end
    end
  end
end

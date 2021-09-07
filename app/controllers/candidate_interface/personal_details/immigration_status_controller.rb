module CandidateInterface
  module PersonalDetails
    class ImmigrationStatusController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted

      def new
        @form = ImmigrationStatusForm.build_from_application(current_application)
      end

      def create
        @form = ImmigrationStatusForm.new(status_params)

        if @form.save(current_application)
          if LanguagesSectionPolicy.hide?(current_application)
            redirect_to candidate_interface_personal_details_show_path
          else
            redirect_to candidate_interface_languages_path
          end
        else
          track_validation_error(@form)
          render :new
        end
      end

    private

      def status_params
        strip_whitespace params.require(
          :candidate_interface_immigration_status_form,
        ).permit(
          :immigration_status,
        )
      end
    end
  end
end

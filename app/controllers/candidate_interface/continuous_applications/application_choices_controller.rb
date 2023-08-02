module CandidateInterface
  module ContinuousApplications
    class ApplicationChoicesController < ::CandidateInterface::ContinuousApplicationsController
      before_action :redirect_to_your_applications_if_submitted

      def confirm_destroy
        @application_choice = application_choice
      end

      def destroy
        CandidateInterface::DeleteApplicationChoice.new(application_choice:).call

        redirect_to candidate_interface_continuous_applications_choices_path
      end

    private

      def redirect_to_your_applications_if_submitted
        redirect_to candidate_interface_continuous_applications_choices_path unless application_choice.unsubmitted?
      end

      def application_choice
        current_application
          .application_choices
          .find(params[:id])
      end
    end
  end
end

module CandidateInterface
  module CourseChoices
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      before_action :redirect_to_application_if_new_applications_stopped
      rescue_from ActiveRecord::RecordNotFound, with: :render_404

    private

      def redirect_to_application_if_new_applications_stopped
        if FeatureFlag.active?(:stop_new_applications)
          flash[:warning] = 'New applications are now closed for 2020'
          redirect_to candidate_interface_application_complete_path and return false
        end
        true
      end
    end
  end
end

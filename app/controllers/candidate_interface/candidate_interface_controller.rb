module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include BasicAuthHelper
    include LogRequestParams
    before_action :require_basic_auth_for_ui
    before_action :authenticate_candidate!
    before_action :add_identity_to_log
    layout 'application'
    alias :audit_user :current_candidate

  private

    def redirect_to_dashboard_if_submitted
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
    end

    def show_pilot_holding_page_if_not_open
      return if FeatureFlag.active?('pilot_open')

      render 'candidate_interface/shared/pilot_holding_page'
    end

    # controller-specific additional info to include in logstash logs
    def add_identity_to_log
      RequestLocals.store[:identity] = { candidate_id: current_candidate&.id }
    end

    def current_application
      @current_application ||= current_candidate.current_application
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end
  end
end

module CandidateInterface
  class CandidateInterfaceController < ActionController::Base
    include LogQueryParams
    before_action :protect_with_basic_auth
    before_action :authenticate_candidate!
    before_action :add_identity_to_log
    layout 'application'
    alias :audit_user :current_candidate

  private

    def redirect_to_dashboard_if_not_amendable
      if FeatureFlag.active?('edit_application')
        redirect_to candidate_interface_application_complete_path unless current_application.amendable?
      elsif current_application.submitted?
        redirect_to candidate_interface_application_complete_path
      end
    end

    def redirect_to_application_form_unless_submitted
      redirect_to candidate_interface_application_form_path unless current_application.submitted?
    end

    def redirect_to_application_if_signed_in
      redirect_to candidate_interface_application_form_path if candidate_signed_in?
    end

    def show_pilot_holding_page_if_not_open
      return if FeatureFlag.active?('pilot_open')

      render 'candidate_interface/shared/pilot_holding_page'
    end

    def add_identity_to_log(candidate_id = current_candidate&.id)
      RequestLocals.store[:identity] = { candidate_id: candidate_id }
      Raven.user_context(candidate_id: candidate_id)

      return unless current_candidate

      Raven.extra_context(application_support_url: support_interface_application_form_url(current_application))
    end

    def current_application
      @current_application ||= current_candidate.current_application
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def protect_with_basic_auth
      # On production this won't be enabled
      return unless ENV['BASIC_AUTH_ENABLED'] == '1'

      authenticate_or_request_with_http_basic do |username, password|
        (username == ENV.fetch('BASIC_AUTH_USERNAME')) && (password == ENV.fetch('BASIC_AUTH_PASSWORD'))
      end
    end
  end
end

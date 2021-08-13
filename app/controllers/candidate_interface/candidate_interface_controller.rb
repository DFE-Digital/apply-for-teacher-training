module CandidateInterface
  class CandidateInterfaceController < ApplicationController
    before_action :protect_with_basic_auth
    before_action :authenticate_candidate!
    before_action :set_user_context
    before_action :check_cookie_preferences
    layout 'application'
    alias audit_user current_candidate
    alias current_user current_candidate

    def set_user_context(candidate_id = current_candidate&.id)
      Sentry.set_user(id: "candidate_#{candidate_id}")

      return unless current_candidate

      Sentry.set_tags(application_support_url: support_interface_application_form_url(current_application))
    end

    def check_cookie_preferences
      if cookies['consented-to-apply-cookies'].eql?('yes')
        @google_analytics_id = ENV.fetch('GOOGLE_ANALYTICS_APPLY', '')
        @google_tag_manager_id = ENV.fetch('GOOGLE_TAG_MANAGER_APPLY', '')
      end
    end

  private

    def redirect_to_dashboard_if_submitted
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
    end

    def redirect_to_application_form_unless_submitted
      redirect_to candidate_interface_application_form_path unless current_application.submitted?
    end

    def redirect_to_application_if_signed_in
      redirect_to candidate_interface_application_form_path if candidate_signed_in?
    end

    def return_to_after_edit(default:)
      if redirect_back_to_application_review_page?
        { back_path: candidate_interface_application_review_path, params: redirect_back_to_application_review_page_params }
      else
        { back_path: default, params: {} }
      end
    end

    def redirect_back_to_application_review_page_params
      { 'return-to' => 'application-review' }
    end

    def redirect_back_to_application_review_page?
      params['return-to'] == 'application-review'
    end

    def application_review_path_and_params
      { path: candidate_interface_application_review_path, params: { 'return-to' => 'application-review' } }
    end

    def show_pilot_holding_page_if_not_open
      return if FeatureFlag.active?('pilot_open')

      render 'candidate_interface/shared/pilot_holding_page'
    end

    def current_application
      @current_application ||= current_candidate.current_application
    end
    helper_method :current_application

    def render_application_feedback_component
      @render_application_feedback_component = true
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def protect_with_basic_auth
      # On production this will not be enabled
      return unless ENV['BASIC_AUTH_ENABLED'] == '1'

      authenticate_or_request_with_http_basic do |username, password|
        (username == ENV.fetch('BASIC_AUTH_USERNAME')) && (password == ENV.fetch('BASIC_AUTH_PASSWORD'))
      end
    end

    def start_date_field_to_attribute(key)
      case key
      when 'start_date(3i)' then 'start_date_day'
      when 'start_date(2i)' then 'start_date_month'
      when 'start_date(1i)' then 'start_date_year'
      else key
      end
    end

    def end_date_field_to_attribute(key)
      case key
      when 'end_date(3i)' then 'end_date_day'
      when 'end_date(2i)' then 'end_date_month'
      when 'end_date(1i)' then 'end_date_year'
      else key
      end
    end

    def strip_whitespace(params)
      StripWhitespace.from_hash(params)
    end

    def append_info_to_payload(payload)
      super

      payload.merge!({ candidate_id: current_candidate&.id })
      payload.merge!(request_query_params)
    end
  end
end

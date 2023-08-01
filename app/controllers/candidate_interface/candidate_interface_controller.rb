module CandidateInterface
  class CandidateInterfaceController < ApplicationController
    before_action :protect_with_basic_auth
    before_action :authenticate_candidate!
    before_action :set_user_context
    before_action :check_cookie_preferences
    before_action :check_account_locked
    before_action :track_email_click
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
        @google_analytics_id   = ENV.fetch('GOOGLE_ANALYTICS_APPLY', '')
        @google_tag_manager_id = ENV.fetch('GOOGLE_TAG_MANAGER_APPLY', '')
      end
    end

  private

    def check_that_candidate_can_accept
      unless ApplicationStateChange.new(@application_choice).can_accept?
        render_404
      end
    end

    def check_that_candidate_has_an_offer
      render_404 unless @application_choice.offer?
    end

    def redirect_to_dashboard_if_submitted
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
    end

    def redirect_to_post_offer_dashboard_if_accepted_or_recruited
      destination_path = if @current_application.continuous_applications?
                           candidate_interface_continuous_applications_choices_path
                         else
                           candidate_interface_application_offer_dashboard_path
                         end

      redirect_to destination_path if any_accepted_offer? || current_application.recruited?
    end

    def redirect_to_new_continuous_applications_if_active
      if current_application.continuous_applications?
        redirect_to candidate_interface_continuous_applications_details_path
      end
    end

    def redirect_to_new_continuous_applications_if_active
      if current_application.continuous_applications?
        redirect_to candidate_interface_continuous_applications_details_path
      end
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
      params['return-to'] == 'application-review' || params[:return_to] == 'application-review'
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
      StripInvisibleWhitespace.from_hash(params)
    end

    def append_info_to_payload(payload)
      super

      payload.merge!({ candidate_id: current_candidate&.id })
      payload.merge!(query_params: request_query_params)
    end

    def check_account_locked
      if current_candidate&.account_locked?
        sign_out(current_candidate)
        redirect_to candidate_interface_account_locked_path
      end
    end

    def track_email_click
      if params[:utm_source].present?
        email = Email.where(notify_reference: params[:utm_source]).first
        email&.email_clicks&.create(path: request.fullpath)
      end
    end

    def redirect_to_completed_dashboard_if_not_accepted
      redirect_to candidate_interface_application_complete_path if no_offers_accepted_and_not_recruited?
    end

    def any_accepted_offer?
      current_application.application_choices.map(&:status).include?('pending_conditions')
    end

    def no_offers_accepted_and_not_recruited?
      !any_accepted_offer? && !current_application.recruited?
    end
  end
end

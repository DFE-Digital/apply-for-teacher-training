module CandidateInterface
  class CandidateInterfaceController < ApplicationController
    include BackLinks

    APPLICATION_CHOICE_CONTROLLER_PATHS = [
      'continuous_applications_choices', # controller for Your applications
      'continuous_applications/course_choices', # the course choice wizard
      'continuous_applications/application_choices', # deleting an application choice
      'decisions', # withdrawing from a course offer
      'candidate_interface/apply_from_find',
    ].freeze

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
        @google_analytics_id = ENV.fetch('GOOGLE_ANALYTICS_APPLY', '')
        @google_tag_manager_id = ENV.fetch('GOOGLE_TAG_MANAGER_APPLY', '')
      end
    end

    # Should the current request be considered as made under the Your
    # applications tab
    def choices_controller?
      return false if current_application.v23?

      @choices_controller ||= begin
        choices_controllers = Regexp.compile(APPLICATION_CHOICE_CONTROLLER_PATHS.join('|'))

        controller_path.match?(choices_controllers) ||
          (controller_path.match('candidate_interface/guidance') && request.referer&.match?('choices'))
      end
    end

    def back_link_text
      if any_offers_accepted_or_deferred_or_recruited?
        'Back to your offer'
      else
        'Back to application'
      end
    end
    helper_method :back_link_text

    def current_application
      @current_application ||= current_candidate.current_application
    end
    helper_method :current_application

  private

    def track_adviser_offering
      Adviser::Tracking.new(current_user, request).candidate_offered_adviser
    end

    def check_that_candidate_can_accept
      return render_404 if @application_choice.nil?

      unless ApplicationStateChange.new(@application_choice).can_accept?
        render_404
      end
    end

    def check_that_candidate_has_an_offer
      render_404 unless @application_choice.offer?
    end

    def redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      return unless current_application.v23?

      redirect_to candidate_interface_application_complete_path if current_application.submitted?
    end

    def redirect_to_details_if_submitted
      redirect_to candidate_interface_continuous_applications_details_path if current_application.submitted?
    end

    def redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      redirect_to candidate_interface_application_offer_dashboard_path if any_offers_accepted_or_deferred_or_recruited?
    end

    def redirect_to_completed_dashboard_if_not_accepted_deferred_or_recruited
      redirect_to candidate_interface_application_complete_path if no_offers_accepted_or_deferred_and_not_recruited?
    end

    def redirect_to_new_continuous_applications_if_eligible
      return if current_application.v23? || current_application.any_offer_accepted?

      completed_application_form = CandidateInterface::CompletedApplicationForm.new(
        application_form: current_application,
      )

      if current_application.application_choices.any? && completed_application_form.valid?
        redirect_to candidate_interface_continuous_applications_choices_path
      else
        redirect_to candidate_interface_continuous_applications_details_path
      end
    end

    def redirect_to_application_if_signed_in
      if candidate_signed_in?
        return redirect_to candidate_interface_application_complete_path if current_application.v23?

        redirect_to_new_continuous_applications_if_eligible
      end
    end

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

    def any_accepted_offer?
      current_application.application_choices.map(&:status).include?('pending_conditions')
    end

    def any_deferred_offer?
      current_application.application_choices.map(&:status).include?('offer_deferred')
    end

    def no_offers_accepted_or_deferred_and_not_recruited?
      !any_accepted_offer? && !current_application.recruited? && !any_deferred_offer?
    end

    def any_offers_accepted_or_deferred_or_recruited?
      any_accepted_offer? || current_application.recruited? || any_deferred_offer?
    end
  end
end

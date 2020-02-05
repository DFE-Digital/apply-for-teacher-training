module RefereeInterface
  class ReferenceController < ActionController::Base
    include LogQueryParams
    before_action :add_identity_to_log
    before_action :check_referee_has_valid_token
    before_action :set_token_param
    before_action :show_finished_page_if_feedback_provided, except: %i[questionnaire submit_questionnaire submit_feedback confirmation confirm_consent]

    layout 'application'

    def feedback
      @application = reference.application_form
      @reference_form = ReferenceFeedbackForm.new(reference: reference)
    end

    def submit_feedback
      @application = reference.application_form

      @reference_form = ReferenceFeedbackForm.new(
        reference: reference,
        feedback: params[:referee_interface_reference_feedback_form][:feedback],
      )

      if @reference_form.save
        redirect_to referee_interface_questionnaire_path(token: @token_param)
      else
        render :feedback
      end
    end

    def questionnaire
      render :questionnaire
    end

    def submit_questionnaire
      render :finish
    end

    def confirmation; end

    def confirm_consent
      consent_to_be_contacted = params.dig(:application_reference, :consent_to_be_contacted)

      reference.update!(consent_to_be_contacted: consent_to_be_contacted)

      render :finish
    end

    def refuse_feedback
      @application = reference.application_form
      @reference = reference
    end

    def confirm_feedback_refusal
      reference.update!(feedback_status: 'feedback_refused')

      send_slack_notification

      SendNewRefereeRequestEmail.call(application_form: @reference.application_form, reference: @reference, reason: :refused)

      redirect_to referee_interface_confirmation_path(token: @token_param)
    end

  private

    def show_finished_page_if_feedback_provided
      return if reference.feedback_requested?

      render :finish
    end

    def add_identity_to_log
      return if reference.blank?

      RequestLocals.store[:identity] = { reference_id: reference.id }
      Raven.user_context(reference_id: reference.id)
    end

    def reference
      @reference ||= ApplicationReference.find_by_unhashed_token(params[:token])
    end

    def set_token_param
      @token_param = params[:token]
    end

    def check_referee_has_valid_token
      render_404 unless reference
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def send_slack_notification
      message = ":sadparrot: A referee declined to give feedback for #{reference.application_form.first_name}'s application"
      url = helpers.support_interface_application_form_url(reference.application_form)

      SlackNotificationWorker.perform_async(message, url)
    end
  end
end

module RefereeInterface
  class ReferenceController < ActionController::Base
    include LogQueryParams
    before_action :add_identity_to_log
    before_action :check_referee_has_valid_token
    before_action :set_token_param
    before_action :show_finished_page_if_feedback_provided, except: %i[submit_feedback submit_questionnaire confirmation finish]


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
        redirect_to referee_interface_confirmation_path(token: @token_param)
      else
        render :feedback
      end
    end

    def submit_questionnaire
      @questionnaire_form = QuestionnaireForm.new(questionnaire_params)

      if @questionnaire_form.save(reference)
        redirect_to referee_interface_finish_path(token: @token_param)
      else
        render :confirmation
      end
    end

    def confirmation
      @questionnaire_form = QuestionnaireForm.new
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

    def finish; end

  private

    def show_finished_page_if_feedback_provided
      return if reference.feedback_requested?

      redirect_to referee_interface_finish_path(token: @token_param)
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

    def questionnaire_params
      params.require(:referee_interface_questionnaire_form).permit(
        :experience_rating, :experience_explanation_very_poor, :experience_explanation_poor,
        :experience_explanation_ok, :experience_explanation_good, :experience_explanation_very_good,
        :guidance_rating, :guidance_explanation_very_poor,
        :guidance_explanation_poor, :guidance_explanation_ok, :guidance_explanation_good,
        :guidance_explanation_very_good, :safe_to_work_with_children,
        :safe_to_work_with_children_explanation, :consent_to_be_contacted,
        :consent_to_be_contacted_details
      )
    end
  end
end

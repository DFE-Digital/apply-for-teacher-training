module RefereeInterface
  class ReferenceController < ActionController::Base
    include LogQueryParams
    before_action :add_identity_to_log
    before_action :check_referee_has_valid_token
    before_action :set_token_param
    before_action :show_finished_page_if_feedback_provided, except: %i[submit_feedback submit_questionnaire confirmation finish]

    layout 'application'

    def audit_user
      reference
    end

    def relationship
      @application = reference.application_form
      @relationship = reference.relationship
      @relationship_form = ReferenceRelationshipForm.build_from_reference(reference: reference)
    end

    def confirm_relationship
      @application = reference.application_form
      @relationship = reference.relationship
      @relationship_form = ReferenceRelationshipForm.new(relationship_params)
      @relationship_form.candidate = reference.application_form.full_name

      if @relationship_form.save(reference)
        if reference.safeguarding_concerns.blank?
          redirect_to referee_interface_safeguarding_path(token: @token_param)
        elsif reference.feedback.blank?
          redirect_to referee_interface_reference_feedback_path(token: @token_param)
        else
          redirect_to referee_interface_reference_review_path(token: @token_param)
        end
      else
        render :relationship
      end
    end

    def safeguarding
      @application = reference.application_form
      @safeguarding_form = ReferenceSafeguardingForm.build_from_reference(reference: reference)
    end

    def confirm_safeguarding
      @application = reference.application_form
      @safeguarding_form = ReferenceSafeguardingForm.new(safeguarding_params)
      @safeguarding_form.candidate = reference.application_form.full_name

      if @safeguarding_form.save(reference)
        if reference.feedback.nil?
          redirect_to referee_interface_reference_feedback_path(token: @token_param)
        else
          redirect_to referee_interface_reference_review_path(token: @token_param)
        end
      else
        render :safeguarding
      end
    end

    def feedback
      @reference_form = ReferenceFeedbackForm.new(
        reference: reference,
        feedback: reference.feedback,
      )
    end

    def submit_feedback
      @reference_form = ReferenceFeedbackForm.new(
        reference: reference,
        feedback: params[:referee_interface_reference_feedback_form][:feedback],
      )

      if @reference_form.save
        redirect_to referee_interface_reference_review_path(token: @token_param)
      else
        render :feedback
      end
    end

    def review
      @reference = reference
    end

    def submit_reference
      SubmitReference.new(reference: reference).save!

      redirect_to referee_interface_confirmation_path(token: @token_param)
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

      SendNewRefereeRequestEmail.call(reference: @reference, reason: :refused)

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
      Raven.extra_context(application_support_url: support_interface_application_form_url(reference.application_form))
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

    def relationship_params
      params.require(:referee_interface_reference_relationship_form)
            .permit(:relationship_correction, :relationship_confirmation)
    end

    def safeguarding_params
      params.require(:referee_interface_reference_safeguarding_form)
            .permit(:any_safeguarding_concerns, :safeguarding_concerns)
    end
  end
end

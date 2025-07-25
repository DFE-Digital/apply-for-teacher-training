module RefereeInterface
  class ReferenceController < ActionController::Base
    include RequestQueryParams

    before_action :set_user_context
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
      @relationship_form = ReferenceRelationshipForm.build_from_reference(reference:)

      @previous_path = previous_path(previous_path_in_flow: referee_interface_refuse_feedback_path(token: @token_param))
    end

    def confirm_relationship
      @application = reference.application_form
      @relationship = reference.relationship
      @relationship_form = ReferenceRelationshipForm.new(relationship_params)
      @relationship_form.candidate = reference.application_form.full_name

      if @relationship_form.save(reference)
        redirect_to review_path_or(referee_interface_safeguarding_path(token: @token_param))
      else
        render :relationship
      end
    end

    def safeguarding
      @application = reference.application_form
      @safeguarding_form = ReferenceSafeguardingForm.build_from_reference(reference:)

      @previous_path = previous_path(previous_path_in_flow: referee_interface_reference_relationship_path(token: @token_param))
    end

    def confirm_safeguarding
      @application = reference.application_form
      @safeguarding_form = ReferenceSafeguardingForm.new(safeguarding_params)
      @safeguarding_form.candidate = reference.application_form.full_name

      if @safeguarding_form.save(reference)
        redirect_to review_path_or(referee_interface_reference_feedback_path(token: @token_param))
      else
        render :safeguarding
      end
    end

    def feedback
      @reference_form = ReferenceFeedbackForm.new(
        reference:,
        feedback: reference.feedback,
      )

      @previous_path = previous_path(previous_path_in_flow: referee_interface_safeguarding_path(token: @token_param))
    end

    def submit_feedback
      @reference_form = ReferenceFeedbackForm.new(
        reference:,
        feedback: params[:referee_interface_reference_feedback_form][:feedback],
      )

      if @reference_form.save
        redirect_to referee_interface_reference_review_path(token: @token_param)
      else
        render :feedback
      end
    end

    def review
      @application = reference.application_form
      @reference_form = ReferenceReviewForm.new(
        reference:,
      )
    end

    def submit_reference
      @reference_form = ReferenceReviewForm.new(
        reference:,
      )

      if @reference_form.valid?
        SubmitReference.new(reference:).save!
        redirect_to referee_interface_confirmation_path(token: @token_param)
      else
        @application = reference.application_form
        render :review
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
      @refuse_feedback_form = RefuseFeedbackForm.build_from_reference(reference:)
      @application = reference.application_form
      @accepted_choice = @application.application_choices.find(&:accepted_choice?)
    end

    def confirm_feedback_refusal
      @refuse_feedback_form = RefuseFeedbackForm.new(refused: refused_params)
      @application = reference.application_form

      render :refuse_feedback and return unless @refuse_feedback_form.valid?

      if @refuse_feedback_form.save(reference)
        if @reference.refused
          redirect_to referee_interface_decline_reference_path(token: @token_param)
        else
          redirect_to referee_interface_confidentiality_path(token: @token_param, from: 'refuse')
        end
      end
    end

    def confidentiality
      @confidentiality_form = ConfidentialityForm.build_from_reference(reference:)
      @application = reference.application_form
      @previous_path = previous_path(previous_path_in_flow: referee_interface_refuse_feedback_path(token: @token_param))
    end

    def confirm_confidentiality
      @confidentiality_form = ConfidentialityForm.new(confidential: confidentiality_params)
      @application = reference.application_form

      render :confidentiality and return unless @confidentiality_form.valid?

      if @confidentiality_form.save(reference)
        redirect_to referee_interface_reference_relationship_path(token: @token_param, from: 'confidentiality')
      end
    end

    def finish
      @reference_cancelled = reference.cancelled?
    end

    def confirm_decline
      @application = reference.application_form
      @confirm_refuse_feedback_form = ConfirmRefuseFeedbackForm.new
    end

    def decline
      ConfirmRefuseFeedbackForm.new.save(reference)
      redirect_to referee_interface_finish_path(token: @token_param)
    end

    def thank_you; end

  private

    def previous_path(previous_path_in_flow:)
      if params[:from] == 'review'
        referee_interface_reference_review_path(token: @token_param)
      elsif params[:from] == 'refuse'
        referee_interface_refuse_feedback_path(token: @token_param)
      elsif params[:from] == 'confidentiality'
        referee_interface_confidentiality_path(token: @token_param)
      elsif previous_path_in_flow
        previous_path_in_flow
      end
    end

    def review_path_or(default_path)
      if params[:from] == 'review'
        referee_interface_reference_review_path(token: @token_param)
      else
        default_path
      end
    end

    def show_finished_page_if_feedback_provided
      return if reference.feedback_requested?

      redirect_to referee_interface_finish_path(token: @token_param)
    end

    def set_user_context
      return if reference.blank?

      Sentry.set_extras(
        application_support_url: support_interface_application_form_url(reference.application_form),
        reference_id: reference.id,
      )
    end

    def append_info_to_payload(payload)
      super

      payload.merge!({ reference_id: reference.id }) if reference.present?
      payload.merge!(query_params: request_query_params)
    end

    def reference
      @reference ||= ApplicationReference.find_by_unhashed_token(params[:token])&.find_latest_reference
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

    def questionnaire_params
      params.expect(referee_interface_questionnaire_form: [*QuestionnaireForm::FORM_KEYS])
    end

    def relationship_params
      params
            .expect(referee_interface_reference_relationship_form: %i[relationship_correction relationship_confirmation])
    end

    def safeguarding_params
      params
            .expect(referee_interface_reference_safeguarding_form: %i[any_safeguarding_concerns safeguarding_concerns])
    end

    def refused_params
      params.dig(:referee_interface_refuse_feedback_form, :refused)
    end

    def confidentiality_params
      params.dig(:referee_interface_confidentiality_form, :confidential)
    end
  end
end

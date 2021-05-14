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
      @relationship_form = ReferenceRelationshipForm.build_from_reference(reference: reference)
    end

    def confirm_relationship
      @application = reference.application_form
      @relationship = reference.relationship
      @relationship_form = ReferenceRelationshipForm.new(relationship_params)
      @relationship_form.candidate = reference.application_form.full_name

      if @relationship_form.save(reference)
        if reference.safeguarding_concerns.blank? || reference.never_asked?
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
      @reference_form = ReferenceReviewForm.new(
        reference: reference,
      )
    end

    def submit_reference
      @reference_form = ReferenceReviewForm.new(
        reference: reference,
      )

      if @reference_form.valid?
        SubmitReference.new(reference: reference).save!
        redirect_to referee_interface_confirmation_path(token: @token_param)
      else
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
      @refuse_feedback_form = RefuseFeedbackForm.new
      @application = reference.application_form
    end

    def confirm_feedback_refusal
      @refuse_feedback_form = RefuseFeedbackForm.new(choice: choice_params)
      @application = reference.application_form

      render :refuse_feedback and return unless @refuse_feedback_form.valid?

      if @refuse_feedback_form.referee_has_confirmed_they_wont_a_reference?
        @refuse_feedback_form.save(reference)
        redirect_to referee_interface_thank_you_path(token: @token_param)
      else
        redirect_to referee_interface_reference_relationship_path(token: @token_param)
      end
    end

    def finish
      @reference_cancelled = reference.cancelled?
      @application_form = reference.application_form
    end

    def thank_you; end

  private

    def show_finished_page_if_feedback_provided
      return if reference.feedback_requested?

      redirect_to referee_interface_finish_path(token: @token_param)
    end

    def set_user_context
      return if reference.blank?

      Raven.extra_context(
        application_support_url: support_interface_application_form_url(reference.application_form),
        reference_id: reference.id,
      )
    end

    def append_info_to_payload(payload)
      super

      payload.merge!({ reference_id: reference.id }) if reference.present?
      payload.merge!(request_query_params)
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

    def questionnaire_params
      params.require(:referee_interface_questionnaire_form).permit(*QuestionnaireForm::FORM_KEYS)
    end

    def relationship_params
      params.require(:referee_interface_reference_relationship_form)
            .permit(:relationship_correction, :relationship_confirmation)
    end

    def safeguarding_params
      params.require(:referee_interface_reference_safeguarding_form)
            .permit(:any_safeguarding_concerns, :safeguarding_concerns)
    end

    def choice_params
      params.dig(:referee_interface_refuse_feedback_form, :choice)
    end
  end
end

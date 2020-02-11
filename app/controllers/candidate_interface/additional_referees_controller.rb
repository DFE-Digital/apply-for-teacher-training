module CandidateInterface
  class AdditionalRefereesController < CandidateInterfaceController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def new
      redirect_to_confirm_if_no_more_reference_needed
      @reference = ApplicationReference.new
    end

    def create
      redirect_to_confirm_if_no_more_reference_needed
      reference = current_application.application_references.build(referee_params.merge(replacement: true))

      if reference.save
        redirect_to_confirm_or_show_another_reference_form
      else
        @reference = reference
        render :new
      end
    end

    def confirm
      redirect_to_dashboard_if_no_references_needed
      @references = not_requested_references
    end

    def request_references
      references_to_confirm = not_requested_references.includes(:application_form).to_a

      references_to_confirm.each do |reference|
        RefereeMailer.reference_request_email(current_candidate.current_application, reference).deliver_now
        reference.update!(feedback_status: 'feedback_requested')
      end

      flash[:success] = I18n.t!('additional_referees.feedback_flash', count: references_to_confirm.size)

      redirect_to candidate_interface_application_form_path
    end

    def edit
      @reference = current_reference
    end

    def update
      if current_reference.update(referee_params)
        redirect_to_confirm_or_show_another_reference_form
      else
        @reference = current_reference
        render :edit
      end
    end

  private

    def current_reference
      @current_reference ||= not_requested_references.find(params[:application_reference_id])
    end

    def not_requested_references
      current_application.application_references.not_requested_yet
    end

    def referee_params
      params.require(:application_reference).permit(
        :name,
        :email_address,
        :relationship,
      ).transform_values(&:strip)
    end

    def redirect_to_dashboard_if_no_references_needed
      return if reference_status.still_more_references_needed?

      redirect_to candidate_interface_application_form_path
    end

    def redirect_to_confirm_or_show_another_reference_form
      if reference_status.needs_to_draft_another_reference?
        redirect_to action: :new
      else
        redirect_to candidate_interface_confirm_additional_referees_path
      end
    end

    def redirect_to_confirm_if_no_more_reference_needed
      return if reference_status.needs_to_draft_another_reference?

      redirect_to candidate_interface_confirm_additional_referees_path
    end

    def reference_status
      @reference_status ||= ReferenceStatus.new(current_application)
    end
  end
end

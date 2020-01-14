module SupportInterface
  class NewRefereeRequestController < SupportInterfaceController
    before_action :set_reference

    def show; end

    def deliver
      application_form = @reference.application_form
      CandidateMailer.new_referee_request(application_form, @reference).deliver

      candidate_email = application_form.candidate.email_address
      audit_comment = t('new_referee_request.not_responded.audit_comment', candidate_email: candidate_email)
      application_comment = SupportInterface::ApplicationCommentForm.new(comment: audit_comment)
      application_comment.save(application_form)

      flash[:success] = t('new_referee_request.not_responded.success')

      redirect_to support_interface_application_form_path(application_form)
    end

  private

    def set_reference
      @reference = ApplicationReference.find(params[:reference_id])
    end
  end
end

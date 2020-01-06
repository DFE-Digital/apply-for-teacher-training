module SupportInterface
  class SurveyEmailsController < SupportInterfaceController
    before_action :set_application_form

    def show; end

    def deliver
      CandidateMailer.survey_email(@application_form).deliver

      candidate_email = @application_form.candidate.email_address
      audit_comment = I18n.t('survey_emails.send.audit_comment', candidate_email: candidate_email)
      application_comment = SupportInterface::ApplicationCommentForm.new(comment: audit_comment)
      application_comment.save(@application_form)

      flash[:success] = t('survey_emails.send.success')

      redirect_to support_interface_application_form_path(@application_form)
    end

  private

    def set_application_form
      @application_form = ApplicationForm.find(params[:application_form_id])
    end
  end
end

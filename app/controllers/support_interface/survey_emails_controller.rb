module SupportInterface
  class SurveyEmailsController < SupportInterfaceController
    before_action :set_application_form

    def show; end

    def deliver
      CandidateMailer.survey_email(@application_form).deliver

      flash[:success] = t('survey_emails.send.success')

      redirect_to support_interface_application_form_path(@application_form)
    end

  private

    def set_application_form
      @application_form = ApplicationForm.find(params[:application_form_id])
    end
  end
end

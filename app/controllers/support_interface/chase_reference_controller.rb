module SupportInterface
  class ChaseReferenceController < SupportInterfaceController
    def show
      @reference = Reference.find(params[:reference_id])
      @application_form = @reference.application_form
    end

    def chase
      @reference = Reference.find(params[:reference_id])
      @application_form = @reference.application_form

      RefereeMailer.reference_request_chaser_email(@application_form, @reference).deliver
      CandidateMailer.reference_chaser_email(@application_form, @reference).deliver

      flash[:success] = t('application_form.referees.chase_success')

      redirect_to support_interface_application_form_path(@application_form)
    end
  end
end

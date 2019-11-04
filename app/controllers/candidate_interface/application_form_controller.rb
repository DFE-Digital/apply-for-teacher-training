module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    def show
      return redirect_to candidate_interface_application_form_path if params[:token]

      if current_candidate.current_application.submitted?
        @application_form = current_candidate.current_application

        render :complete
      else
        @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_candidate.current_application)

        render :show
      end
    end

    def review
      @application_form = current_candidate.current_application
    end

    def submit_show
      @further_information_form = FurtherInformationForm.new
    end

    def submit
      @further_information_form = FurtherInformationForm.new(further_information_params)
      application_form = current_candidate.current_application

      if @further_information_form.save(application_form)
        SubmitApplication.new(application_form).call

        redirect_to candidate_interface_application_submit_success_path
      else
        render :submit_show
      end
    end

    def submit_success
      @support_reference = current_candidate.current_application.support_reference
    end

  private

    def further_information_params
      params.require(:candidate_interface_further_information_form).permit(
        :further_information,
        :further_information_details,
      )
    end
  end
end

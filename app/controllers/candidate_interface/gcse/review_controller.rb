module CandidateInterface
  class Gcse::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    before_action :set_subject

    def show
      @application_form = current_application
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)
    end

    def complete
      attribute_to_update = "#{@subject}_gcse_completed"
      value = params.dig('application_form', 'gcse_completed')

      current_application.update!("#{attribute_to_update}": value)

      redirect_to candidate_interface_application_form_path
    end

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end
  end
end

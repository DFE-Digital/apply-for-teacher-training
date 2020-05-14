module CandidateInterface
  class Gcse::ReviewController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def show
      @application_form = current_application
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)
    end

    def complete
      update_gcse_completed(params.dig('application_form', 'gcse_completed'))

      redirect_to candidate_interface_application_form_path
    end
  end
end

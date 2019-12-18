module CandidateInterface
  class Gcse::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    before_action :set_subject

    def show
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)
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

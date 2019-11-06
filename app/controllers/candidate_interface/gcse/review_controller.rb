module CandidateInterface
  class Gcse::ReviewController < CandidateInterfaceController
    before_action :set_subject

    def show
      @application_qualification = ApplicationQualification.last
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

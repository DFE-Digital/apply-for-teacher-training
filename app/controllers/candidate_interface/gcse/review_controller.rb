module CandidateInterface
  class Gcse::ReviewController < CandidateInterfaceController
    before_action :set_subject

    def show
      @application_qualification = current_qualification
    end

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def current_qualification
      current_candidate
        .current_application
        .application_qualifications
        .where(level: ApplicationQualification.levels[:gcse], subject: subject_param)
        .first
    end
  end
end

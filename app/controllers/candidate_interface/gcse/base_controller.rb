module CandidateInterface
  class Gcse::BaseController < SectionController
    before_action :set_subject
    before_action :render_application_feedback_component

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def current_qualification
      @current_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end
  end
end

module CandidateInterface
  class OtherQualifications::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :render_application_feedback_component

    def current_qualification
      @current_qualification ||= current_application.application_qualifications.other.find(params[:id])
    end
  end
end

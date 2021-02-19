module CandidateInterface
  class Gcse::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject
    before_action :render_application_feedback_component

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def update_gcse_completed(value)
      attribute_to_update = "#{@subject}_gcse_completed"
      current_application.update!("#{attribute_to_update}": value)
    end

    def details_form
      @details_form ||= GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
    end

    def current_qualification
      @current_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def details_params
      strip_whitespace params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year other_grade])
    end
  end
end

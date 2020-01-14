module CandidateInterface
  class Gcse::DetailsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    before_action :set_subject

    def edit
      @application_qualification = details_form
      @qualification_type = details_form.qualification.qualification_type
    end

  private

    def set_subject
      @subject = subject_param
    end

    def subject_param
      params.require(:subject)
    end

    def details_params
      params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year])
    end

    def details_form
      @details_form ||= GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
    end
  end
end

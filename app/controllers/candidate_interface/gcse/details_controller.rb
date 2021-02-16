module CandidateInterface
  class Gcse::DetailsController < Gcse::BaseController

    def edit
      @application_qualification = details_form
      @qualification_type = details_form.qualification.qualification_type
    end

  private

    def details_params
      strip_whitespace params.require(:candidate_interface_gcse_qualification_details_form).permit(%i[grade award_year other_grade])
    end

    def details_form
      @details_form ||= GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
    end
  end
end

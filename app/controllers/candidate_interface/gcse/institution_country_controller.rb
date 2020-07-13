module CandidateInterface
  class Gcse::InstitutionCountryController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @institution_country = find_or_build_qualification_form
    end

  private

    def find_or_build_qualification_form
      current_qualification = current_application.qualification_in_subject(:gcse, subject_param)

      if current_qualification
        GcseInstitutionCountryForm.build_from_qualification(current_qualification)
      else
        GcseInstitutionCountryForm.new(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
      end
    end
  end
end

module CandidateInterface
  class Gcse::NewInternationalFlow::InstitutionCountryController < Gcse::NewInternationalFlow::BaseController
    def new
      @institution_country_form = GcseInstitutionCountryForm.build_from_qualification(current_qualification)
    end

    def edit
      @institution_country_form = GcseInstitutionCountryForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @institution_country_form = GcseInstitutionCountryForm.new(institution_country_params)

      if @institution_country_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_structured_qualifications_path
      else
        track_validation_error(@institution_country_form)
        render :new
      end
    end

    def update
      @institution_country_form = GcseInstitutionCountryForm.new(institution_country_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @institution_country_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@institution_country_form)
        render :edit
      end
    end

  private

    def institution_country_params
      strip_whitespace params
        .expect(candidate_interface_gcse_institution_country_form: [:institution_country])
    end
  end
end

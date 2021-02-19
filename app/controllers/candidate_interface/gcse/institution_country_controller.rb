module CandidateInterface
  class Gcse::InstitutionCountryController < Gcse::BaseController
    def edit
      @institution_country = GcseInstitutionCountryForm.build_from_qualification(current_qualification)
    end

    def update
      @institution_country = GcseInstitutionCountryForm.new(institution_country_params)

      if @institution_country.save(current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@institution_country)
        render :edit
      end
    end

  private

    def institution_country_params
      strip_whitespace params
        .require(:candidate_interface_gcse_institution_country_form)
        .permit(:institution_country)
    end

    def next_gcse_path
      if current_qualification.grade.nil?
        candidate_interface_gcse_details_edit_naric_path
      else
        candidate_interface_gcse_review_path
      end
    end
  end
end

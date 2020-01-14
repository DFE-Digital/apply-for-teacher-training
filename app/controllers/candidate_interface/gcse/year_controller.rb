module CandidateInterface
  class Gcse::YearController < Gcse::DetailsController
    def update
      @qualification_type = details_form.qualification.qualification_type

      details_form.award_year = details_params[:award_year]

      @application_qualification = details_form.save_year

      if @application_qualification
        redirect_to candidate_interface_gcse_review_path
      else
        @application_qualification = details_form

        render :edit
      end
    end
  end
end

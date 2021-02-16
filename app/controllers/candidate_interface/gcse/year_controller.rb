module CandidateInterface
  class Gcse::YearController < Gcse::BaseController
    def edit
      @application_qualification = details_form
      @qualification_type = details_form.qualification.qualification_type
    end

    def update
      @application_qualification = details_form
      @qualification_type = details_form.qualification.qualification_type

      details_form.award_year = details_params[:award_year]

      if @application_qualification.save_year
        update_gcse_completed(false)

        redirect_to candidate_interface_gcse_review_path
      else
        track_validation_error(@application_qualification)

        render :edit
      end
    end
  end
end

module CandidateInterface
  class Gcse::YearController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted

    def update
      @qualification_type = details_form.qualification.qualification_type

      details_form.award_year = details_params[:award_year]

      @application_qualification = details_form.save_year

      if @application_qualification
        redirect_to candidate_interface_gcse_review_path
      else
        @application_qualification = details_form
        track_validation_error(@application_qualification)

        render :edit
      end
    end
  end
end

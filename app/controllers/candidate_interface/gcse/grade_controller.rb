module CandidateInterface
  class Gcse::GradeController < Gcse::DetailsController
    def update
      @qualification_type = details_form.qualification.qualification_type

      details_form.grade = details_params[:grade]

      @application_qualification = details_form.save_grade

      if @application_qualification
        redirect_to next_gcse_path
      else
        @application_qualification = details_form

        render :edit
      end
    end

  private

    def next_gcse_path
      if details_form.award_year.nil?
        candidate_interface_gcse_details_edit_year_path
      else
        candidate_interface_gcse_review_path
      end
    end
  end
end

module CandidateInterface
  class OtherQualifications::BaseController < CandidateInterfaceController
    def new
      @qualification = OtherQualificationForm.new
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)
      application_form = current_candidate.current_application

      if @qualification.save(application_form)
        redirect_to candidate_interface_review_other_qualifications_path
      else
        render :new
      end
    end

  private

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :award_year
      )
    end
  end
end

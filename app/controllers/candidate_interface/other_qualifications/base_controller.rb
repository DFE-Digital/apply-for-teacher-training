module CandidateInterface
  class OtherQualifications::BaseController < CandidateInterfaceController
    def new
      @qualification = OtherQualificationForm.new
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.save(current_application)
        redirect_to candidate_interface_review_other_qualifications_path
      else
        render :new
      end
    end

    def edit
      @qualification = OtherQualificationForm.build_from_application(current_application, current_other_qualification_id)
    end

    def update
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.update(current_application)
        redirect_to candidate_interface_review_other_qualifications_path
      else
        render :edit
      end
    end

  private

    def current_other_qualification_id
      params.permit(:id)[:id]
    end

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :award_year
      )
    end
  end
end

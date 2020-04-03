module CandidateInterface
  class OtherQualifications::TypeController < CandidateInterfaceController
    def new
      @qualification_type = OtherQualificationTypeForm.new
    end

    def create
      @qualification_type = OtherQualificationTypeForm.new(other_qualification_type_params)
      if @qualification_type.save(current_application)
        redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
      else
        render :new
      end
    end

  private

    def other_qualification_type_params
      params.require(:candidate_interface_other_qualification_type_form).permit(
        :qualification_type,
      )
    end
  end
end

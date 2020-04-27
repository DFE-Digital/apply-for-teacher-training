module CandidateInterface
  class OtherQualifications::TypeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @qualification_type = OtherQualificationTypeForm.new
    end

    def create
      @qualification_type = OtherQualificationTypeForm.new(other_qualification_type_params)
      if @qualification_type.save(current_application)
        redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
      else
        track_validation_error(@qualification_type)
        render :new
      end
    end

  private

    def other_qualification_type_params
      params.fetch(:candidate_interface_other_qualification_type_form, {}).permit(
        :qualification_type,
      )
    end
  end
end

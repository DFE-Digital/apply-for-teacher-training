module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
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

    def edit
      @qualification_type = OtherQualificationTypeForm.build_from_qualification(ApplicationQualification.find(params[:id]))
    end

    def update
      @qualification_type = OtherQualificationTypeForm.new(other_qualification_type_params)

      if qualification_type_has_changed && @qualification_type.update(current_qualification)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_edit_other_qualification_details_path(current_qualification)
      elsif @qualification_type.update(current_qualification)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification_type)
        render :edit
      end
    end

  private

    def other_qualification_type_params
      params.fetch(:candidate_interface_other_qualification_type_form, {}).permit(
        :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
      )
    end

    def qualification_type_has_changed
      @qualification_type.qualification_type != current_qualification.qualification_type
    end
  end
end

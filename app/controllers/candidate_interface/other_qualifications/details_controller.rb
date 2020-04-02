module CandidateInterface
  class OtherQualifications::DetailsController < CandidateInterfaceController
    def new
      qualifications = OtherQualificationForm.build_all_from_application(current_application)
      last_qualification = qualifications[-2]
      @type = qualifications.last.qualification_type

      @qualification = if @type == last_qualification&.qualification_type
                         OtherQualificationForm.new(
                           institution_name: last_qualification.institution_name,
                           award_year: last_qualification.award_year,
                         )
                       else
                         OtherQualificationForm.new
                       end
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.valid? && @qualification.choice == 'same_type'
        @qualification.save(current_application)
        qualification = ApplicationQualification.find(params[:id])

        @qualification_type = OtherQualificationTypeForm.new(
          qualification_type: qualification.qualification_type,
        )

        @qualification_type.save(current_application)

        redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
      elsif @qualification.valid? && @qualification.choice == 'different_type'
        @qualification.save(current_application)

        redirect_to candidate_interface_new_other_qualification_type_path
      elsif @qualification.valid? && @qualification.choice == 'no'
        @qualification.save(current_application)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        qualifications = OtherQualificationForm.build_all_from_application(current_application)
        @type = qualifications.last.qualification_type

        render :new
      end
    end

  private

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :award_year, :choice
      ).merge!(id: params[:id]).transform_values(&:strip)
    end
  end
end

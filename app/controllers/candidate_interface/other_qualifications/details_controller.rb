module CandidateInterface
  class OtherQualifications::DetailsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      qualifications = OtherQualificationForm.build_all_from_application(current_application)
      @type = qualifications.last.qualification_type

      @qualification = if last_two_qualifications_are_of_same_type(qualifications)
                         OtherQualificationForm.new(
                           institution_name: pre_fill_institution_name(qualifications),
                           award_year: pre_fill_award_year(qualifications),
                         )
                       else
                         OtherQualificationForm.new
                       end
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.valid?
        @qualification.save

        if @qualification.choice == 'same_type'
          qualification = ApplicationQualification.find(params[:id])

          @qualification_type = OtherQualificationTypeForm.new(
            qualification_type: qualification.qualification_type,
          )

          @qualification_type.save(current_application)

          redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
        elsif @qualification.choice == 'different_type'
          redirect_to candidate_interface_new_other_qualification_type_path
        elsif @qualification.choice == 'no'
          redirect_to candidate_interface_review_other_qualifications_path
        end
      else
        qualifications = OtherQualificationForm.build_all_from_application(current_application)
        @type = qualifications.last.qualification_type
        track_validation_error(@qualification)

        render :new
      end
    end

  private

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :id, :subject, :institution_name, :grade, :award_year, :choice
      ).merge!(id: params[:id], qualification_type: get_qualification_type).transform_values(&:strip)
    end

    def last_two_qualifications_are_of_same_type(qualifications)
      second_to_last_qualification = qualifications[-2]
      last_qualification = qualifications[-1]
      second_to_last_qualification&.qualification_type == last_qualification.qualification_type
    end

    def pre_fill_institution_name(qualifications)
      qualifications[-2].institution_name
    end

    def pre_fill_award_year(qualifications)
      qualifications[-2].award_year
    end

    def get_qualification_type
      ApplicationQualification.find(params[:id]).qualification_type
    end
  end
end

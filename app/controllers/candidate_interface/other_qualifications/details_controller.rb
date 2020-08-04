module CandidateInterface
  class OtherQualifications::DetailsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      qualifications = OtherQualificationForm.build_all_from_application(current_application)
      @qualification = OtherQualificationForm.pre_fill_new_qualification(qualifications)
      @type = @qualification.set_type(current_application.application_qualifications.last)
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.save

        if @qualification.choice == 'same_type'
          @qualification_type = OtherQualificationTypeForm.new(
            qualification_type: @qualification.qualification_type,
            non_uk_qualification_type: @qualification.non_uk_qualification_type,
            other_uk_qualification_type: @qualification.other_uk_qualification_type,
          )

          @qualification_type.save(current_application)

          redirect_to candidate_interface_new_other_qualification_details_path(id: current_application.application_qualifications.last.id)
        elsif @qualification.choice == 'different_type'
          redirect_to candidate_interface_new_other_qualification_type_path
        elsif @qualification.choice == 'no'
          redirect_to candidate_interface_review_other_qualifications_path
        end
      else
        track_validation_error(@qualification)
        @type = @qualification.set_type(get_qualification)

        render :new
      end
    end

    def edit
      @qualification = OtherQualificationForm.build_from_qualification(current_application.application_qualifications.find(params[:id]))
      @type = @qualification.set_type(get_qualification)
    end

    def update
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.update(current_application)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification)
        @type = @qualification.set_type(get_qualification)

        render :edit
      end
    end

  private

    def other_qualification_params
      if FeatureFlag.active?('international_other_qualifications')
        params.require(:candidate_interface_other_qualification_form).permit(
          :subject, :institution_name, :grade, :award_year, :choice, :institution_country
        ).merge!(id: params[:id],
                 qualification_type: get_qualification.qualification_type,
                 non_uk_qualification_type: get_qualification.non_uk_qualification_type,
                 other_uk_qualification_type: get_qualification.other_uk_qualification_type)
      else
        params.require(:candidate_interface_other_qualification_form).permit(
          :subject, :institution_name, :grade, :award_year, :choice, :institution_country,
          :other_uk_qualification_type, :non_uk_qualification_type
        ).merge!(
          id: params[:id],
          qualification_type: params.dig('candidate_interface_other_qualification_form', 'qualification_type') || get_qualification.qualification_type,
        )
      end
    end

    def get_qualification
      @get_qualification ||= ApplicationQualification.find(params[:id])
    end
  end
end

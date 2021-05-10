module CandidateInterface
  class OtherQualifications::DetailsController < OtherQualifications::BaseController
    def new
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        current_step: :details,
      )

      unless @form.qualification_type
        @form.qualification_type = params[:qualification_type]
        @form.save_intermediate!
      end

      @form.initialize_from_last_qualification(
        current_application.application_qualifications.other.order(:created_at),
      )
    end

    def create
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_params.merge(current_step: :details),
      )

      if @form.save
        if @form.choice == 'same_type'
          intermediate_data_service.clear_state!
          redirect_to candidate_interface_other_qualification_details_path(qualification_type: current_application.application_qualifications.last.qualification_type)
        elsif @form.choice == 'different_type'
          redirect_to candidate_interface_other_qualification_type_path
        else
          redirect_to candidate_interface_review_other_qualifications_path
        end
      else
        track_validation_error(@form)
        render :new
      end
    end

    def edit
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        id: params[:id],
        current_step: :details,
        editing: true,
      )
    end

    def update
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_update_params.merge(
          id: params[:id],
          current_step: :details,
          editing: true,
        ),
      )

      if @form.save
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@form)
        render :edit
      end
    end

  private

    def other_qualification_params
      strip_whitespace params
        .require(:candidate_interface_other_qualification_details_form).permit(
          :subject,
          :grade,
          :award_year,
          :choice,
          :institution_country,
          :other_uk_qualification_type,
          :non_uk_qualification_type,
        )
        .merge!(id: params[:id])
    end

    def other_qualification_update_params
      other_qualification_params.merge(
        strip_whitespace(
          params
          .require(:candidate_interface_other_qualification_details_form)
          .permit(:qualification_type),
        ),
      )
    end
  end
end

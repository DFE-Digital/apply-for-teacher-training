module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
      # Clear any data that's left from the previous time the candidate used the
      # "new qualification" flow.
      intermediate_data_service.clear_state!

      @form = OtherQualificationTypeForm.new(
        current_application,
        intermediate_data_service,
        { current_step: :type }.merge!(qualification_type: params[:change] == 'true' ? 'no_other_qualifications' : nil),
      )
    end

    def create
      @form = OtherQualificationTypeForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_type_params.merge(current_step: :type),
      )

      if @form.no_other_qualification?
        if @form.save_no_other_qualifications
          redirect_to candidate_interface_review_other_qualifications_path
        else
          track_validation_error(@form)
          render :new
        end
      elsif @form.save_intermediate
        redirect_to candidate_interface_other_qualification_details_path
      else
        track_validation_error(@form)
        render :new
      end
    end

    def edit
      @form = OtherQualificationTypeForm.new(
        current_application,
        intermediate_data_service,
        {
          current_step: :type,
          editing: true,
        }.merge!(type_attributes(current_qualification)),
      )
      @form.save_intermediate!
    end

    def update
      @form = OtherQualificationTypeForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_type_params.merge(
          current_step: :type,
          editing: true,
          id: current_qualification.id,
        ),
      )

      if @form.valid?
        @form.save_intermediate!

        next_step = @form.next_step

        if next_step == :details
          redirect_to candidate_interface_edit_other_qualification_details_path(current_qualification.id)
        elsif next_step == :check
          @form.save!
          redirect_to candidate_interface_review_other_qualifications_path
        else
          render :edit
        end
      else
        track_validation_error(@form)
        render :edit
      end
    end

  private

    def type_attributes(application_qualification)
      application_qualification.attributes.extract!(
        *CandidateInterface::OtherQualificationTypeForm::PERSISTENT_ATTRIBUTES,
      )
    end

    def other_qualification_type_params
      strip_whitespace params
        .fetch(:candidate_interface_other_qualification_type_form, {})
        .permit(:qualification_type, :other_uk_qualification_type, :non_uk_qualification_type, :no_other_qualification)
    end
  end
end

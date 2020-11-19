module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
      reset_intermediate_state!
      @form = form_for(current_step: :type)
      @form.save_intermediate!
    end

    def create
      @form = form_for(other_qualification_type_params.merge(current_step: :type))

      if @form.valid?
        @form.save_intermediate!

        next_step = @form.next_step

        if next_step == :details
          redirect_to candidate_interface_other_qualification_details_path
        else
          track_validation_error(@form)
          render :new
        end
      else
        track_validation_error(@form)
        render :new
      end
    end

    def edit
      @form = form_for(
        current_step: :type,
        initialize_from_db: true,
        checking_answers: true,
      )
      @form.save_intermediate!
    end

    def update
      @form = form_for(
        other_qualification_type_params.merge(
          current_step: :type,
          checking_answers: true,
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
          reset_intermediate_state!
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

    def form_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      if options.delete(:initialize_from_db)
        options.merge!(type_attributes(current_qualification)) if params[:id]
      end

      OtherQualificationTypeForm.new(
        current_application,
        intermediate_data_service,
        options,
      )
    end

    def other_qualification_type_params
      params.fetch(:candidate_interface_other_qualification_type_form, {}).permit(
        :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
      )
    end
  end
end

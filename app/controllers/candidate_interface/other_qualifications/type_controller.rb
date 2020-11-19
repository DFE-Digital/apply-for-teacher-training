module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
      reset_intermediate_state!
      @form = form_for(current_step: :type)
    end

    def create
      @form = form_for(other_qualification_type_params.merge(current_step: :type))

      if @form.valid?(:type)
        @form.save!

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
      @form = form_for(current_step: :type)
      @form.copy_attributes(current_qualification)
      @form.save!
    end

    def update
      @form = form_for(
        other_qualification_type_params.merge(
          current_step: :type,
          checking_answers: true,
          id: current_qualification.id,
        ),
      )
      if @form.valid?(:type)
        @form.save!

        next_step = @form.next_step

        if next_step == :details
          redirect_to candidate_interface_edit_other_qualification_details_path(current_qualification.id)
        elsif next_step == :check
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

    def form_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      OtherQualificationTypeForm.new(
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

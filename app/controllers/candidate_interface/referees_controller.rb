module CandidateInterface
  class RefereesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    before_action :redirect_to_review_referees_if_amendable_and_two_referees_are_present, except: %i[index review destroy confirm_destroy cancel_referee_request]
    before_action :set_referee, only: %i[edit update confirm_destroy destroy cancel_referee_request]
    before_action :set_referees, only: %i[type update_type new create index review]

    def index
      unless @referees.empty?
        redirect_to candidate_interface_review_referees_path
      end
    end

    def type
      if params[:id]
        set_referee_id

        @reference_type_form = Reference::RefereeTypeForm.build_from_reference(@referee)
      else
        @reference_type_form = Reference::RefereeTypeForm.new
      end
    end

    def update_type
      @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)

      if params[:id]
        set_referee_id

        return redirect_to action: 'type', id: @id unless @reference_type_form.valid?

        @reference_type_form.save(@referee)

        redirect_to candidate_interface_review_referees_path
      else
        return render :type unless @reference_type_form.valid?

        redirect_to candidate_interface_new_referee_path(type: referee_type_param)
      end
    end

    def new
      @referee = if FeatureFlag.active?('referee_type')
                   current_candidate.current_application.application_references.build(referee_type: params[:type])
                 else
                   current_candidate.current_application.application_references.build
                 end
    end

    def create
      @referee = current_candidate.current_application
                                  .application_references
                                  .build(referee_params)
      @referee.referee_type = params[:type] if FeatureFlag.active?('referee_type')

      if @referee.save
        redirect_to candidate_interface_review_referees_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @referee.update(referee_params)
        redirect_to candidate_interface_review_referees_path
      else
        render :edit
      end
    end

    def confirm_destroy
      @application_form = current_application
    end

    def cancel_referee_request
      @referee.update!(feedback_status: 'cancelled')
      RefereeMailer.reference_cancelled_email(current_application, @referee).deliver_later

      redirect_to candidate_interface_additional_referee_type_path
    end

    def destroy
      @referee.destroy!

      redirect_to candidate_interface_referees_path
    end

    def review
      @application_form = current_candidate.current_application
    end

  private

    def set_referee
      @referee = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
                                    .find(params[:id])
    end

    def set_referee_id
      set_referee

      @id = @referee.id
    end

    def set_referees
      @referees = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
    end

    def referee_type_param
      params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
    end

    def referee_params
      params.require(:application_reference).permit(
        :name,
        :email_address,
        :relationship,
      )
        .transform_values(&:strip)
    end

    def redirect_to_review_referees_if_amendable_and_two_referees_are_present
      redirect_to candidate_interface_review_referees_path if current_application.amendable? && current_application.application_references.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end
  end
end

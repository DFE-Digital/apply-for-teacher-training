module CandidateInterface
  class RefereesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, except: %i[confirm_cancel cancel]
    before_action :set_referee, only: %i[edit update confirm_destroy destroy confirm_cancel cancel]
    before_action :set_referees, only: %i[type update_type new create index review]
    before_action :set_nth_referee, only: %i[type new]

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

        unless @reference_type_form.valid?
          track_validation_error(@reference_type_form)
          return redirect_to action: 'type', id: @id
        end

        @reference_type_form.save(@referee)

        redirect_to candidate_interface_review_referees_path
      else
        return render :type unless @reference_type_form.valid?

        redirect_to candidate_interface_new_referee_path(type: referee_type_param)
      end
    end

    def new
      @referee = current_candidate.current_application.application_references.build(referee_type: params[:type])
    end

    def create
      @referee = current_candidate.current_application
                                  .application_references
                                  .build(referee_params)
      @referee.referee_type = params[:type]

      if @referee.save
        redirect_to candidate_interface_review_referees_path
      else
        track_validation_error(@referee)
        render :new
      end
    end

    def edit
      @nth_referee = "#{TextOrdinalizer::ORDINALIZE_MAPPING[@referee.ordinal].capitalize} referee"
    end

    def update
      if @referee.update(referee_params)
        redirect_to candidate_interface_review_referees_path
      else
        track_validation_error(@referee)
        render :edit
      end
    end

    def confirm_cancel
      if @referee.feedback_requested?
        @application_form = current_application
      else
        redirect_to candidate_interface_review_referees_path
      end
    end

    def cancel
      if @referee.feedback_requested?
        CancelReferee.new.call(reference: @referee)

        redirect_to candidate_interface_additional_referee_type_path
      else
        redirect_to candidate_interface_review_referees_path
      end
    end

    def confirm_destroy; end

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

    def set_nth_referee
      @nth_referee = "#{TextOrdinalizer::ORDINALIZE_MAPPING[(@referees.count + 1)].capitalize} referee"
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
  end
end

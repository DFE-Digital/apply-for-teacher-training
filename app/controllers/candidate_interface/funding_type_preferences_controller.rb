module CandidateInterface
  class FundingTypePreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_back_path

    def new
      if @preference.published?
        @preference = @preference.create_draft_dup
      end

      @funding_type_preference_form = FundingTypePreferenceForm.new(
        {
          funding_type: @preference.funding_type,
          preference: @preference,
        },
      )
    end

    def create
      @funding_type_preference_form = FundingTypePreferenceForm.new(
        funding_type: funding_type_params[:funding_type],
        preference: @preference,
      )

      if @funding_type_preference_form.save!
        redirect_to candidate_interface_draft_preference_path(@preference)
      else
        render :new
      end
    end

  private

    def funding_type_params
      params.fetch(:candidate_interface_funding_type_preference_form, {}).permit(:funding_type)
    end

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params.expect(:draft_preference_id))

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end

    def set_back_path
      @back_path = FundingTypePreferenceForm.new({ preference: @preference })
        .back_path(return_to: params[:return_to])
    end
  end
end

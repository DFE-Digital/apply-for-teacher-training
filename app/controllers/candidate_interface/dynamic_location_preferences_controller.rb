module CandidateInterface
  class DynamicLocationPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_back_path, only: :new

    def new
      if @preference.published?
        @preference = @preference.create_draft_dup
      end

      @dynamic_location_preferences_form = DynamicLocationPreferencesForm.new(
        {
          dynamic_location_preferences: @preference.dynamic_location_preferences,
          preference: @preference,
        },
      )
    end

    def create
      @dynamic_location_preferences_form = DynamicLocationPreferencesForm.new(
        form_params.merge(preference: @preference),
      )

      if @dynamic_location_preferences_form.valid?
        @dynamic_location_preferences_form.save
        redirect_to @dynamic_location_preferences_form.next_path(return_to: params[:return_to])
      else
        set_back_path
        render :new
      end
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end

    def set_back_path
      @back_path = if params[:return_to] == 'review'
                     candidate_interface_draft_preference_path(@preference)
                   else
                     candidate_interface_draft_preference_location_preferences_path(@preference)
                   end
    end

    def form_params
      params.fetch(:candidate_interface_dynamic_location_preferences_form, {}).permit(
        :dynamic_location_preferences,
      )
    end
  end
end

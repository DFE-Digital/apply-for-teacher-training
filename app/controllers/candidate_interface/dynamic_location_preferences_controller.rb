module CandidateInterface
  class DynamicLocationPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_back_path, only: :new
    before_action :redirect_to_root_path_if_flag_is_inactive

    def new
      @dynamic_location_preferences_form = DynamicLocationPreferencesForm.build_from_preference(
        preference: @preference,
      )
    end

    def create
      @dynamic_location_preferences_form = DynamicLocationPreferencesForm.new(
        {
          dynamic_location_preferences: form_params[:dynamic_location_preferences],
          preference: @preference,
        },
      )

      if @dynamic_location_preferences_form.valid?
        @dynamic_location_preferences_form.save
        redirect_to candidate_interface_draft_preference_path(@preference)
      else
        set_back_path
        render :new
      end
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
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

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

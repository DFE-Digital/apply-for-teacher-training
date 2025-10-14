module CandidateInterface
  class DraftPreferencesController < CandidateInterfaceController
    before_action :set_preference, only: %i[show update]

    def show
      @location_preferences = @preference.location_preferences.order(:created_at).map do |location|
        LocationPreferenceDecorator.new(location)
      end

      @back_path = if params[:return_to] == 'application-sharing'
                     candidate_interface_invites_path
                   else
                     LocationPreferencesRequiredForm.new(preference: @preference).back_path
                   end
    end

    def update
      @preference_form = LocationPreferencesRequiredForm.new(
        preference: @preference,
      )

      if @preference_form.valid?
        redirect_to redirect_path
      else
        @location_preferences = @preference.location_preferences
        render 'candidate_interface/location_preferences/index'
      end
    end

  private

    def redirect_path
      if params[:return_to] == 'review'
        candidate_interface_draft_preference_path(@preference)
      else
        new_candidate_interface_draft_preference_dynamic_location_preference_path(@preference)
      end
    end

    def request_params
      params.fetch(:candidate_interface_preferences_form, {}).permit(
        :dynamic_location_preferences,
      )
    end

    def set_preference
      @preference = current_application.preferences.find_by(id: params[:id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end
  end
end

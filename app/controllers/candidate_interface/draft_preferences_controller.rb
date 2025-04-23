module CandidateInterface
  class DraftPreferencesController < CandidateInterfaceController
    before_action :set_preference, only: %i[show update]
    before_action :redirect_to_root_path_if_flag_is_inactive

    def show
      @location_preferences = @preference.location_preferences.order(:created_at).map do |location|
        CandidateInterface::LocationPreferenceDecorator.new(location)
      end
    end

    def update
      @preference_form = PreferencesForm.new(
        preference: @preference,
        params: request_params,
      )

      if @preference_form.save
        redirect_to candidate_interface_draft_preference_path(@preference)
      else
        @location_preferences = @preference.location_preferences
        render 'candidate_interface/location_preferences/index'
      end
    end

  private

    def request_params
      params.fetch(:candidate_interface_preferences_form, {}).permit(
        :dynamic_location_preferences,
      )
    end

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:id])

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
      end
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

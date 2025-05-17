module CandidateInterface
  class LocationPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_location_preference, only: %i[edit update show destroy]
    before_action :set_back_path, only: %i[index]
    before_action :redirect_to_root_path_if_flag_is_inactive

    def index
      if @preference.published?
        @preference = @preference.create_draft_dup
      end

      @location_preferences = @preference.location_preferences.order(:created_at).map do |location|
        LocationPreferenceDecorator.new(location)
      end
      @preference_form = PreferencesForm.build_from_preference(
        preference: @preference,
      )
    end

    def show; end

    def new
      @location_preference_form = LocationPreferencesForm.new(preference: @preference)
    end

    def edit
      @location_preference_form = LocationPreferencesForm.build_from_location_preference(
        preference: @preference,
        location_preference: @location_preference,
      )
    end

    def create
      @location_preference_form = LocationPreferencesForm.new(
        preference: @preference,
        params: location_preference_params,
      )

      if @location_preference_form.save
        redirect_to candidate_interface_draft_preference_location_preferences_path(@preference)
      else
        render :new
      end
    end

    def update
      @location_preference_form = LocationPreferencesForm.new(
        preference: @preference,
        location_preference: @location_preference,
        params: location_preference_params,
      )

      if @location_preference_form.save
        redirect_to candidate_interface_draft_preference_location_preferences_path(@preference)
      else
        render :edit
      end
    end

    def destroy
      @location_preference.destroy!

      redirect_to candidate_interface_draft_preference_location_preferences_path(@preference)
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
      end
    end

    def set_location_preference
      @location_preference = @preference.location_preferences.find_by(id: params[:id])

      if @location_preference.blank?
        redirect_to candidate_interface_draft_preference_location_preferences_path(
          @preference,
        )
      end
    end

    def location_preference_params
      params.expect(candidate_interface_location_preferences_form: %i[name within])
    end

    def set_back_path
      if params[:return_to] == 'review'
        @back_path = candidate_interface_draft_preference_path(@preference)
      end
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
    end
  end
end

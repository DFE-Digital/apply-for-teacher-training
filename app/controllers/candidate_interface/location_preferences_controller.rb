module CandidateInterface
  class LocationPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :set_location_preference, only: %i[edit update]

    def index
      @location_preferences = @preference.location_preferences.where(status: %i[draft selected]).order(:location)
    end

    def new
      @location_preference = CandidateLocationPreference.new
    end

    def edit; end

    def create
      geocoder_location = Geocoder.search(location_preference_params[:location], components: 'country:UK').first
      # Return error if this api call fails?
      # Add coordinates in a background job?

      @location_preference = @preference.location_preferences.new(
        within: location_preference_params[:within],
        location: location_preference_params[:location],
        latitude: geocoder_location.latitude,
        longitude: geocoder_location.longitude,
      )

      if @location_preference.save
        redirect_to candidate_interface_preference_location_preferences_path(@preference)
      else
        render :new
      end
    end

    def update
      geocoder_location = Geocoder.search(location_preference_params[:location], components: 'country:UK').first

      @location_preference.assign_attributes(
        within: location_preference_params[:within],
        location: location_preference_params[:location],
        latitude: geocoder_location.latitude,
        longitude: geocoder_location.longitude,
      )

      if @location_preference.save
        redirect_to candidate_interface_preference_location_preferences_path(@preference)
      else
        render :edit
      end
    end

  private

    def location_preference_params
      params.expect(candidate_location_preference: %i[within location])
    end

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params.require(:preference_id))
    end

    def set_location_preference
      @location_preference = @preference.location_preferences.find_by(
        id: params.require(:id),
      )
    end
  end
end

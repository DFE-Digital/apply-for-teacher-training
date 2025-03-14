module CandidateInterface
  class LocationPreferencesController < CandidateInterfaceController
    def index
      @preference = current_candidate.preferences.find_by(id: params.require(:preference_id))

      @location_preferences = @preference.location_preferences.where(status: %i[draft selected]).order(:location)
    end

    def new
      @location_preference = CandidateInterface::LocationPreference.new
    end

    def edit; end

    def create
      @location_preference = current_candidate.location_preferences.new(
        within: location_preference_params[:within],
        location: location_preference_params[:location],
      )

      if @location_preference.valid?
        @location_preference.save!
        redirect_to candidate_interface_location_preferences_path
      else
        render :new
      end
    end

    def update; end

  private

    def location_preference_params
      params.expect(candidate_interface_location_preference: %i[within location])
    end
  end
end

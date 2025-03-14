module CandidateInterface
  class PreferencesController < CandidateInterfaceController
    before_action :redirect_to_edit_if_preference_exist
    before_action :set_preference, only: %i[show edit update]
    ## GEt the last draft?

    def show
      @selected_locations = @preference_record.location_preferences.selected
    end

    def new
      @preference = CandidateInterface::PreferencesForm.new(current_candidate:)
    end

    def edit
      @preference = CandidateInterface::PreferencesForm.build_from_preference(
        current_candidate:,
        preference: @preference_record,
      )
    end

    def create
      @preference = CandidateInterface::PreferencesForm.new(
        current_candidate:,
        preference_params:,
      )

      if @preference.save
        redirect_to @preference.redirect_path
      else
        render :new
      end
    end

    def update
      @preference = CandidateInterface::PreferencesForm.new(
        current_candidate:,
        preference_params:,
      )

      if @preference.save
        redirect_to candidate_interface_preference_path(@preference.id)
      else
        render :edit
      end
    end

  private

    def preference_params
      # move this in the form object?
      {
        pool_status: params.fetch(:candidate_interface_preferences_form, {})[:pool_status],
        dynamic_location_preferences: params.fetch(:candidate_preference, {})[:dynamic_location_preferences],
        location_preference_ids: params.fetch(:candidate_preference, {})[:location_preferences]&.compact_blank,
        id: params[:id],
      }
    end

    def redirect_to_edit_if_preference_exist
      if current_candidate.preferences.published.any?
        redirect_to edit_candidate_interface_preference_path(current_candidate.current_preference)
      end
    end

    def set_preference
      @preference_record = current_candidate.preferences.find_by(id: params.require(:id))
    end
  end
end

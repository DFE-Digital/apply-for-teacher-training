module CandidateInterface
  class PublishPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :redirect_to_root_path_if_flag_is_inactive

    def show
      @location_preferences = @preference.location_preferences.order(:created_at).map do |location|
        LocationPreferenceDecorator.new(location)
      end
    end

    def create
      ActiveRecord::Base.transaction do
        @preference.published!
        if @preference.training_locations_anywhere?
          @preference.update(dynamic_location_preferences: nil)
          @preference.location_preferences.destroy_all
        end
        current_candidate.published_preferences.where.not(id: @preference.id).destroy_all
        current_candidate.duplicated_preferences.where.not(id: @preference.id).destroy_all
        PreferencesEmail.call(preference: @preference)
      end

      flash[:success] = t('.success_opt_out') if @preference.opt_out?

      redirect_to show_candidate_interface_pool_opt_ins_path
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

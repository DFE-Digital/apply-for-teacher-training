module CandidateInterface
  class PublishPreferencesController < CandidateInterfaceController
    before_action :set_preference

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
        current_application.published_preferences.where.not(id: @preference.id).destroy_all
        current_application.duplicated_preferences.where.not(id: @preference.id).destroy_all
      end
      if @preference.reload.published?
        PreferencesEmail.call(preference: @preference)
      end

      if current_application.notifications.pool_opt_in.any?
        flash[:success] = t('.success')
        redirect_to candidate_interface_invites_path
      else
        redirect_to show_candidate_interface_pool_opt_ins_path
      end
    end

  private

    def set_preference
      @preference = current_application.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end
  end
end

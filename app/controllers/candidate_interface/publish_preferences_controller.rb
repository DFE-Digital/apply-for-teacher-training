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
        archive_all(current_candidate.published_preferences.where.not(id: @preference.id))
        current_candidate.duplicated_preferences.where.not(id: @preference.id).destroy_all
      end
      if @preference.reload.published?
        PreferencesEmail.call(preference: @preference)
      end

      if @preference.opt_out?
        redirect_to candidate_interface_invites_path
        flash[:success] = t('.success_opt_out')
      elsif opting_back_in?
        redirect_to candidate_interface_invites_path
        flash[:success] = [t('.success_opt_back_in'),
                           view_context.link_to(t('.application_sharing_guidance'), candidate_interface_share_details_path, class: 'govuk-notification-banner__link')]
      elsif updating_existing_preference?
        redirect_to candidate_interface_invites_path
        flash[:success] = [t('.success_updated_options'),
                           view_context.link_to(t('.application_sharing_guidance'), candidate_interface_share_details_path, class: 'govuk-notification-banner__link')]
      else
        redirect_to show_candidate_interface_pool_opt_ins_path
      end
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_invites_path
      end
    end

    def archive_all(preferences)
      preferences.update_all(status: 'archived')
    end

    def opting_back_in?
      @preference.opt_in? && current_candidate.archived_preferences.any?(&:opt_out?)
    end

    def updating_existing_preference?
      @preference.opt_in? && current_candidate.archived_preferences.last&.opt_in?
    end
  end
end

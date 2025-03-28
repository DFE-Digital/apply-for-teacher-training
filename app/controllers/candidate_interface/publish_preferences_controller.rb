module CandidateInterface
  class PublishPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :redirect_to_root_path_if_flag_is_inactive

    def show; end

    def create
      ActiveRecord::Base.transaction do
        @preference.published!
        current_candidate.published_preferences.where.not(id: @preference.id).destroy_all
      end

      flash[:success] = t('.success')
      redirect_to candidate_interface_application_choices_path
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

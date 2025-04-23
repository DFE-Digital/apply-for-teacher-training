module CandidateInterface
  class PublishPreferencesController < CandidateInterfaceController
    before_action :set_preference
    before_action :redirect_to_root_path_if_flag_is_inactive

    def show
      @location_preferences = @preference.location_preferences.order(:created_at).map do |location|
        CandidateInterface::LocationPreferenceDecorator.new(location)
      end
    end

    def create
      ActiveRecord::Base.transaction do
        @preference.published!
        current_candidate.published_preferences.where.not(id: @preference.id).destroy_all
      end

      flash[:success] = if @preference.opt_in?
                          t('.success_opt_in')
                        else
                          t('.success_opt_out')
                        end

      # This will have no effect if the candidate has not been sent the email
      exp = FieldTest::Experiment.find('find_a_candidate/candidate_feature_launch_email')
      if @preference.opt_in?
        exp.convert(current_candidate, goal: :opt_in)
      else
        exp.convert(current_candidate, goal: :opt_out)
      end

      redirect_to candidate_interface_application_choices_path
    end

  private

    def set_preference
      @preference = current_candidate.preferences.find_by(id: params[:draft_preference_id])

      if @preference.blank?
        redirect_to candidate_interface_application_choices_path
      end
    end

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

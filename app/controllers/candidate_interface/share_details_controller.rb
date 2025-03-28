module CandidateInterface
  class ShareDetailsController < CandidateInterfaceController
    before_action :redirect_to_root_path_if_flag_is_inactive

    def index; end

  private

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences)
    end
  end
end

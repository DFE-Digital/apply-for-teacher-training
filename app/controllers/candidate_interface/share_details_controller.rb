module CandidateInterface
  class ShareDetailsController < CandidateInterfaceController
    before_action :redirect_to_root_path_if_flag_is_inactive

    def index
      @submit_application = params[:submit_application] == 'true'
      @back_path = if @submit_application
                     candidate_interface_application_choices_path
                   else
                     candidate_interface_invites_path
                   end
    end

  private

    def redirect_to_root_path_if_flag_is_inactive
      redirect_to root_path unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
    end
  end
end

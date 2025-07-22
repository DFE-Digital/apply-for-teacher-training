module CandidateInterface
  class InvitesController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :redirect_if_feature_off_and_no_submitted_application

    def index
      @invites = current_application.published_invites.includes(:application_choice)
    end

    def show
      @invite = Pool::Invite.find(params[:id])
    end

    def redirect_if_feature_off_and_no_submitted_application
      unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
        redirect_to root_path
      end
    end
  end
end

module ProviderInterface
  class CandidatesController < ProviderInterfaceController
    before_action :disable_on_production, only: :impersonate

    def impersonate
      candidate = Candidate.find(params[:candidate_id])

      if verify_provider_association(candidate: candidate, providers: current_provider_user.providers)
        bypass_sign_in(candidate, scope: :candidate)

        flash[:success] = "You are now signed in as candidate #{candidate.email_address}"

        redirect_to candidate_interface_interstitial_path
      else
        flash[:warning] = 'This candidate is not associated with your account'

        redirect_to provider_interface_applications_path
      end
    end

  private

    def verify_provider_association(candidate:, providers:)
      application_choices = candidate.application_forms.map(&:application_choices).flatten

      (application_choices.map(&:associated_providers).flatten & providers).any?
    end

    def disable_on_production
      return unless HostingEnvironment.production?

      head :not_found
    end
  end
end

module ProviderInterface
  class CandidatesController < ProviderInterfaceController
    before_action :disable_on_production, only: :impersonate

    def impersonate
      candidate = Candidate.find(params[:candidate_id])

      if verify_provider_association(candidate: candidate, providers: current_provider_user.providers)
        bypass_sign_in(candidate, scope: :candidate)

        flash[:success] = "You are now signed in as candidate #{candidate.email_address}"

        redirect_to candidate_interface_application_form_path
      else
        flash[:warning] = 'This candidate is not associated with your account'

        redirect_to provider_interface_applications_path
      end
    end

  private

    def verify_provider_association(candidate:, providers:)
      provider_ids_from_candidate = candidate.application_forms. \
                                              map(&:application_choices).flatten. \
                                              map(&:provider).map(&:id).uniq

      providers.any? { |provider| provider_ids_from_candidate.include? provider.id }
    end

    def disable_on_production
      return unless HostingEnvironment.production?

      head :not_found
    end
  end
end

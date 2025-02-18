module ProviderInterface
  class FindCandidatesController < ProviderInterfaceController
    include Pagy::Backend
    before_action :redirect_to_applications_if_no_candidate_pool_invitation

    def index
      @pagy, @candidates = pagy(
        Pool::Candidates.for_provider(
          providers: current_provider_user.providers,
        ).includes(:application_forms).where(
          application_forms: { recruitment_cycle_year: RecruitmentCycleTimetable.current_year },
        ).order('application_forms.submitted_at'),
      )
    end

  private

    def redirect_to_applications_if_no_candidate_pool_invitation
      invites = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

      redirect_to provider_interface_applications_path if invites.blank?
    end
  end
end

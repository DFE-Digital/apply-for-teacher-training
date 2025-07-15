module SupportInterface
  class DocsController < SupportInterfaceController
    def index; end

    def provider_flow; end

    def candidate_flow; end

    def qualifications; end

    def mailer_previews
      @previews = [
        Candidate::AuthenticationMailerPreview,
        Candidate::ApplicationUnsubmittedPreview,
        Candidate::ApplicationSubmittedPreview,
        Candidate::InterviewPreview,
        Candidate::OffersPreview,
        Candidate::ReferencesPreview,
        Candidate::WithdrawalsAndRejectionsPreview,
        Candidate::EndOfCyclePreview,
        Candidate::FindACandidatePreview,
        Provider::AuthenticationMailerPreview,
        Provider::OrganisationPermissionsMailerPreview,
        Provider::ApplicationsMailerPreview,
        Provider::DeadlinesMailerPreview,
        Provider::ReferencesMailerPreview,
        Referee::ReferencesMailerPreview,
        Support::AuthenticationMailerPreview,
      ].uniq
    end

    def component_previews
      @previews_grouped_by_namespace = ViewComponent::Preview.all.reverse.group_by { |p| p.name.split('::').first }
      @page_title = 'Components Previews'
    end
  end
end

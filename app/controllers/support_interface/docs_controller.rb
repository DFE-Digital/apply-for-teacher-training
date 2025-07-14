module SupportInterface
  class DocsController < SupportInterfaceController
    def index; end

    def provider_flow; end

    def candidate_flow; end

    def qualifications; end

    def mailer_previews
      all_mailer_previews = ActionMailer::Preview.all
      candidate_mailers = [
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
      ].filter { |mailer_preview| all_mailer_previews.include? mailer_preview }
      # This is to preserve the order of the candidate mailers - we want them to reflect the stages of the cycle
      @previews = (candidate_mailers + all_mailer_previews).uniq
    end

    def component_previews
      @previews_grouped_by_namespace = ViewComponent::Preview.all.reverse.group_by { |p| p.name.split('::').first }
      @page_title = 'Components Previews'
    end
  end
end

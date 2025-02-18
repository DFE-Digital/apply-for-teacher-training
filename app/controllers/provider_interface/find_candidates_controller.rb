module ProviderInterface
  class FindCandidatesController < ProviderInterfaceController
    include Pagy::Backend
    before_action :redirect_to_applications_if_no_candidate_pool_invitation

    def index
      @pagy, @candidates = pagy(
        Pool::Candidates.for_provider(providers: current_provider_user.providers),
      )
    end

  private

    def redirect_to_applications_if_no_candidate_pool_invitation
      invites = CandidatePoolProviderInvitation.find_by(id: current_provider_user.provider_ids)

      redirect_to provider_interface_applications_path if invites.blank?
    end
  end
end

## What do we display on the index page? What columns?
## What is the distance in relation to? A candidate can apply to multiple providers/courses. Do we find the closest ones?
## Do we include candidates that had withdrawn?
## Filters? last course applied to for location, as the crow flies? public transport driving?

## On show page, a candidate can have multiple courses
## Can we agree on the designs? For example on the invite page, there are a lot of suggestions. Or should I just go ahead and put something in front of people and then decide?

## Selecting a course, do we want radio buttons, for 1 option or multiple? Or no option at all?

# Withdrawn candidates as well
# Don't include withdrawn because they don't want to be a teacher. Opt out every one that doesn't want to be a teacher in the future and the past

class CandidateInterface::ManagePreferencesComponent < ViewComponent::Base
  attr_reader :current_candidate

  def initialize(current_candidate)
    @current_candidate = current_candidate
  end

  def render?
    FeatureFlag.active?(:candidate_preferences)
  end

private

  def links_list
    list = [
      govuk_link_to(
        'Read about how sharing your application details works',
        candidate_interface_share_details_path,
      ),
    ]

    if current_candidate.published_preferences.any?
      list.unshift(
        govuk_link_to(
          'Change your sharing and location settings',
          candidate_interface_draft_preference_publish_preferences_path(current_candidate.published_preferences.last),
        ),
      )
    end

    list
  end
end

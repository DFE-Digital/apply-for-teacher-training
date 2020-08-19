module ProviderInterface
  class DiversityInformationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user
    end

    def message
      return 'The candidate disclosed information in the equality and diversity questionnaire.' if diversity_information_declared?

      'No information shared'
    end

    def display_diversity_information?
      diversity_information_declared? && current_user_has_permission_to_view_diversity_information? && application_in_correct_state?
    end

    def details
      if [current_user_has_permission_to_view_diversity_information?, application_in_correct_state?].all?(false)
        return 'This will become available to users with permissions to `view diversity information` when an offer has been accepted'
      end

      return 'You will be able to view this when an offer has been accepted.' if current_user_has_permission_to_view_diversity_information?

      'This section is only available to users with permissions to `view diversity information`.' if application_in_correct_state?
    end

    def rows
      rows = [{ key: 'Sex', value: equality_and_diversity['sex'].capitalize },
              { key: 'Ethnic group', value: equality_and_diversity['ethnic_group'] }]
      rows << { key: 'Ethnic background', value: equality_and_diversity['ethnic_background'] } if equality_and_diversity['ethnic_background'].present?
      rows << { key: 'Disabled', value: disability_status }
      rows << { key: 'Disabilities', value: disability_value.html_safe } if disability_status == 'Yes'
      rows
    end

    def diversity_information_declared?
      application_choice.application_form.equality_and_diversity_answers_provided?
    end

  private

    def disability_status
      return 'Prefer not to say' if equality_and_diversity['disabilities'].include?('Prefer not to say')

      return 'Yes' if equality_and_diversity['disabilities'].any?

      'No'
    end

    def disability_value
      disabilities = equality_and_diversity['disabilities'].map do |disability|
        "<li>#{disability} </li>"
      end

      "<p class=\"govuk-body govuk-margin-top-0>\">The candidate disclosed the following #{'disability'.pluralize(disabilities.count)}:</p>
      <ul class=\"govuk-list govuk-list--bullet\">#{disabilities.join}</ul>"
    end

    def application_in_correct_state?
      ApplicationStateChange::POST_OFFERED_STATES.include?(application_choice.status.to_sym)
    end

    def current_user_has_permission_to_view_diversity_information?
      current_provider_user.authorisation
        .can_view_diversity_information?(course: application_choice.course)
    end

    def equality_and_diversity
      @equality_and_diversity ||= application_choice.application_form.equality_and_diversity
    end
  end
end

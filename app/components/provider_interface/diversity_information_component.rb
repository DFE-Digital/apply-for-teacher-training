module ProviderInterface
  class DiversityInformationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user
    end

    def message
      return declared_diversity_information_message if diversity_information_declared?

      'No information shared'
    end

    def display_diversity_information?
      diversity_information_declared? && current_user_has_permission_to_view_diversity_information? && application_in_correct_state?
    end

    def details
      if [current_user_has_permission_to_view_diversity_information?, application_in_correct_state?].all?(false)
        return "Users with permission to see this information will only be able to do so after #{offer_context} offer has been accepted by the candidate."
      end

      return "You’ll only be able to see this information after #{offer_context} offer has been accepted by the candidate." if current_user_has_permission_to_view_diversity_information?

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

    def offer_context
      application_choice.offer? ? 'your' : 'an'
    end

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

    def declared_diversity_information_message
      'The candidate disclosed information in the optional equality and diversity questionnaire. This relates to their sex, ethnicity and disability status. We collect this data to help reduce discrimination on these grounds. (This is not the same as the information we request relating to the candidate’s disability, access and other needs).'
    end
  end
end

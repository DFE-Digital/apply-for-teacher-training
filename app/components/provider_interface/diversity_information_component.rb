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

    def details
      if [current_user_has_permission_to_view_diversity_information?, application_in_correct_state?].all?(false)
        return 'This will become available to users with permissions to `view diversity information` when an offer has been accepted'
      end

      return 'You will be able to view this when an offer has been accepted.' if current_user_has_permission_to_view_diversity_information?

      'This section is only available to users with permissions to `view diversity information`.' if application_in_correct_state?
    end

    def diversity_information_declared?
      application_choice.application_form.equality_and_diversity_answers_provided?
    end

  private

    def application_in_correct_state?
      ApplicationStateChange::POST_OFFERED_STATES.include?(application_choice.status.to_sym)
    end

    def current_user_has_permission_to_view_diversity_information?
      current_provider_user.authorisation
        .can_view_diversity_information?(course: application_choice.course)
    end
  end
end

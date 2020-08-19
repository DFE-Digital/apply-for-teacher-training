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

  private

    def diversity_information_declared?
      application_choice.application_form.equality_and_diversity_answers_provided?
    end
  end
end

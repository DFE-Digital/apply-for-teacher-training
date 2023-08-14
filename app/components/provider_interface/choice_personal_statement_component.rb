module ProviderInterface
  class ChoicePersonalStatementComponent < ViewComponent::Base
    delegate :personal_statement,
             to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

  private

    attr_reader :application_choice
  end
end

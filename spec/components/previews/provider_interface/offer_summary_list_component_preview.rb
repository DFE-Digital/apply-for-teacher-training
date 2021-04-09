module ProviderInterface
  class OfferSummaryListComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def application_choice_with_offer
      render_component_for choices: ApplicationChoice.where(status: :offer)
    end

    def application_choice_without_offer
      render_component_for choices: ApplicationChoice.where(status: :awaiting_provider_decision)
    end

  private

    def render_component_for(choices:)
      if !choices.empty?
        render ProviderInterface::OfferSummaryListComponent.new(application_choice: choices.order('RANDOM()').first)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end

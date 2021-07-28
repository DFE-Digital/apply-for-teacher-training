module ProviderInterface
  class StatusBoxComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def awaiting_provider_decision
      render_component_for choices: ApplicationChoice.where(status: :awaiting_provider_decision)
    end

    def offer
      render_component_for choices: ApplicationChoice.where(status: :offer)
    end

    def pending_conditions_with_conditions
      render_component_for choices: ApplicationChoice.where(
        'status = \'pending_conditions\' AND offer IS NOT NULL AND offer->>\'conditions\' != \'[]\'',
      )
    end

    def pending_conditions_with_no_conditions
      render_component_for choices: ApplicationChoice.where('status = \'pending_conditions\' AND offer->>\'conditions\' = \'[]\'')
    end

    def rejected
      render_component_for choices: ApplicationChoice.where(status: :rejected)
    end

    def recruited
      render_component_for choices: ApplicationChoice.where(status: :recruited)
    end

    def enrolled
      render_component_for choices: ApplicationChoice.where(status: :enrolled)
    end

    def declined
      render_component_for choices: ApplicationChoice.where(status: :declined)
    end

    def conditions_not_met
      render_component_for choices: ApplicationChoice.where(status: :conditions_not_met)
    end

    def application_withdrawn
      render_component_for choices: ApplicationChoice.where(status: :withdrawn)
    end

    def offer_withdrawn
      render_component_for choices: ApplicationChoice.where(status: :offer_withdrawn)
    end

  private

    def render_component_for(choices:)
      if choices.any?
        render ProviderInterface::StatusBoxComponent.new(application_choice: choices.order('RANDOM()').first)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end

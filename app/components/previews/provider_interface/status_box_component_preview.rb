module ProviderInterface
  class StatusBoxComponentPreview < ActionView::Component::Preview
    def awaiting_provider_decision
      render_component_for ApplicationChoice.find_by(status: :awaiting_provider_decision)
    end

    def offer
      render_component_for ApplicationChoice.find_by(status: :offer)
    end

    def pending_conditions_with_conditions
      render_component_for ApplicationChoice.find_by(
        'status = \'pending_conditions\' AND offer IS NOT NULL AND offer->>\'conditions\' != \'[]\'',
      )
    end

    def pending_conditions_with_no_conditions
      render_component_for ApplicationChoice.find_by('status = \'pending_conditions\' AND offer->>\'conditions\' = \'[]\'')
    end

    def rejected
      render_component_for ApplicationChoice.find_by(status: :rejected)
    end

    def recruited
      render_component_for ApplicationChoice.find_by(status: :recruited)
    end

    def enrolled
      render_component_for ApplicationChoice.find_by(status: :enrolled)
    end

    def declined
      render_component_for ApplicationChoice.find_by(status: :declined)
    end

    def conditions_not_met
      render_component_for ApplicationChoice.find_by(status: :conditions_not_met)
    end

    def application_withdrawn
      render_component_for ApplicationChoice.find_by('status = \'withdrawn\' AND offer_withdrawn_at IS NULL')
    end

    def offer_withdrawn
      render_component_for ApplicationChoice.find_by('status = \'rejected\' AND offer_withdrawn_at IS NOT NULL')
    end

  private

    def render_component_for(application_choice)
      if application_choice
        render(ProviderInterface::StatusBoxComponent, application_choice: application_choice)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end

class CandidateInterface::ApplicationChoiceItemComponentPreview < ViewComponent::Preview
  def unsubmitted
    render_component(:unsubmitted)
  end

  def awaiting_provider_decision
    render_component(:awaiting_provider_decision)
  end

  def rejected
    render_component(:rejected)
  end

  def offer
    render_component(:offer)
  end

  class CandidateInterface::ApplicationChoiceItemOfferWithDeadlineComponent < CandidateInterface::ApplicationChoiceItemComponent
    def show_decline_by_default_text?
      true
    end
  end

  def offer_upcoming_deadline
    choice = ApplicationChoice.where(status: :offer).last

    render(CandidateInterface::ApplicationChoiceItemOfferWithDeadlineComponent.new(application_choice: choice))
  end

  def pending_conditions
    render_component(:pending_conditions)
  end

  def interviewing
    render_component(:interviewing)
  end

  def withdrawn
    render_component(:withdrawn)
  end

  def offer_withdrawn
    render_component(:offer_withdrawn)
  end

  def declined
    render_component(:declined)
  end

  def inactive
    render_component(:inactive)
  end

private

  def render_component(status)
    choice = ApplicationChoice.where(status:).last

    render(CandidateInterface::ApplicationChoiceItemComponent.new(application_choice: choice))
  end
end

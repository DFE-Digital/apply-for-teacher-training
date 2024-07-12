module CandidateInterface
  class CarryOverAlertPreview < ViewComponent::Preview
    def twenty_twenty_four
      application_form = ApplicationForm.new(recruitment_cycle_year: 2024)

      render CandidateInterface::CarryOverAlertComponent.new(application_form:)
    end
  end

  class CandidateInterface::CarryOverAlertComponent < CandidateInterface::CarryOverInsetTextComponent
    def render?
      true
    end
  end
end

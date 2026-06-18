class CandidateInterface::ApplicationChoices::JanuaryStartContentComponentPreview < ViewComponent::Preview
  def default
    application_choice
    render CandidateInterface::ApplicationChoices::JanuaryStartContentComponent.new(application_form:)
  end

private

  def application_form
    @application_form ||= FactoryBot.build(:application_form)
  end

  def application_choice
    FactoryBot.create_list(:application_choice, 2, application_form: application_form)
  end
end

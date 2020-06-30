module SupportInterface
  class ApplicationStatusTagComponentPreview < ViewComponent::Preview
    ApplicationStateChange.valid_states.each do |state_name|
      define_method state_name do
        render SupportInterface::ApplicationStatusTagComponent.new(application_choice: FactoryBot.build_stubbed(:application_choice, status: state_name))
      end
    end
  end
end

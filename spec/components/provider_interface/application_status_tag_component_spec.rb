require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(application_choice: FactoryBot.build_stubbed(:application_choice, status: state_name))
    end
  end
end

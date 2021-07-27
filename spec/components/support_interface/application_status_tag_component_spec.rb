require 'rails_helper'

RSpec.describe SupportInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(status: state_name.to_s)
    end
  end
end

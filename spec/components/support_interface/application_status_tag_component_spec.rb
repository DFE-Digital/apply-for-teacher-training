require 'rails_helper'

RSpec.describe SupportInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      application_choice = instance_double(ApplicationChoice, status: state_name)

      render_inline described_class.new(application_choice:)
    end
  end

  it 'renders with `ske_pending_condition` supplementary status for `recruited` applications' do
    application_choice = instance_double(
      ApplicationChoice,
      status: :recruited,
      supplementary_statuses: [:ske_pending_conditions],
    )

    result = render_inline described_class.new(application_choice:)
    expect(result.text).to include('Recruited')
    expect(result.text).to include('SKE conditions pending')
  end
end

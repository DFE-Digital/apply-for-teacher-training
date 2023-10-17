require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(application_choice: build_stubbed(:application_choice, status: state_name))
    end
  end

  it 'renders with `ske_pending_condition` supplementary status for `recruited` applications' do
    application_choice = build_stubbed(
      :application_choice,
      status: :recruited,
    )
    allow(application_choice).to receive(:supplementary_statuses).and_return([:ske_pending_conditions])

    result = render_inline described_class.new(application_choice:)
    expect(result.text).to include('Recruited')
    expect(result.text).to include('SKE conditions pending')
  end
end

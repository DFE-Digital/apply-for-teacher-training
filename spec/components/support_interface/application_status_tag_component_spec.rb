require 'rails_helper'

RSpec.describe SupportInterface::ApplicationStatusTagComponent do
  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(status: state_name.to_s)
    end
  end

  it 'renders with `ske_pending_condition` supplementary status for `recruited` applications' do
    result = render_inline described_class.new(
      status: :recruited,
      supplementary_statuses: [:ske_pending_conditions],
    )
    expect(result.text).to include('Recruited')
    expect(result.text).to include('SKE conditions pending')
  end
end

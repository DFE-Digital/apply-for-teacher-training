require 'rails_helper'

RSpec.describe RefereeInterface::FeedbackHintsComponent do
  let(:reference) { build_stubbed(:reference, referee_type: :academic) }

  it 'displays the academic skills bullet point' do
    result = render_inline(described_class.new(reference: reference))

    expect(result.text).to include('academic skills')
  end
end

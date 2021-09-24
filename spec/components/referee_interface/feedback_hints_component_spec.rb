require 'rails_helper'

RSpec.describe RefereeInterface::FeedbackHintsComponent do
  context 'when it is an academic reference' do
    let(:reference) { build_stubbed(:reference, referee_type: :academic) }

    it 'displays the academic skills bullet point' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.text).to include('academic skills')
    end
  end

  context 'when it is non-academic reference' do
    let(:reference) { build_stubbed(:reference, referee_type: :school_based) }

    it 'does not display that the academic skills bullet point' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.text).not_to include('academic skills')
    end
  end
end

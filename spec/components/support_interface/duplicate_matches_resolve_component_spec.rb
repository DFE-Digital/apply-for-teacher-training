require 'rails_helper'

RSpec.describe SupportInterface::DuplicateMatchesResolveComponent do
  subject(:result) do
    render_inline(
      described_class.new(@fraud_match1),
    )
  end

  before do
    @fraud_match1 = create(
      :fraud_match,
      resolved: resolved,
    )
  end

  context 'when duplicate match is resolved' do
    let(:resolved) { true }

    it 'shows button to unresolve duplicate match' do
      expect(result.css('input[type="submit"]')[0].values).to include('Mark as unresolved')
    end
  end

  context 'when duplicate match is not resolved' do
    let(:resolved) { false }

    it 'shows button to resolve duplicate match' do
      expect(result.css('input[type="submit"]')[0].values).to include('Mark as resolved')
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ProviderSelectionStep do
  subject(:provider_selection_step) { described_class.new(provider_id: provider_id) }

  let(:provider_id) { 123 }

  it 'returns the correct next step' do
    expect(provider_selection_step.next_step).to eq(:which_course_are_you_applying_to)
  end

  context 'when no provider_id given' do
    let(:provider_id) { nil }

    it 'validation fails' do
      expect(provider_selection_step).not_to be_valid
    end
  end

  context 'when valid provider_id given' do
    it 'validation passes' do
      expect(provider_selection_step).to be_valid
    end
  end
end

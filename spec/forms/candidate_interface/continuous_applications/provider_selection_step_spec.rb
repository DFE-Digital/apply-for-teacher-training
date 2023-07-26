require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ProviderSelectionStep do
  subject(:provider_selection_step) { described_class.new(provider_id: provider_id) }

  let(:provider_id) { 123 }

  it 'returns the correct next step' do
    expect(provider_selection_step.next_step).to eq(:which_course_are_you_applying_to)
  end

  context 'when no provider_id given' do
    it 'validation fails' do
      expect(provider_selection_step).to validate_presence_of(:provider_id)
    end
  end
end

require 'rails_helper'

RSpec.describe DataMigrations::ProviderInterviewDataFix do
  let(:provider) { create(:provider, name: 'The Manchester Metropolitan University') }

  context 'when additional details are empty' do
    it 'transfer location to additional details' do
      interview = create(
        :interview,
        provider: provider,
        location: 'An email will be sent to you with all the details.',
        additional_details: '',
      )

      described_class.new.change

      interview.reload
      expect(interview.location).to eq('')
      expect(interview.additional_details).to eq('An email will be sent to you with all the details.')
    end
  end

  context 'when additional details are present' do
    it 'amend additional details with location' do
      interview = create(
        :interview,
        provider: provider,
        location: 'An email will be sent to you with all the details.',
        additional_details: 'This is also our last scheduled interview session.',
      )

      described_class.new.change

      interview.reload
      expect(interview.location).to eq('')
      expect(interview.additional_details).to eq(
        "This is also our last scheduled interview session.\nAn email will be sent to you with all the details.",
      )
    end
  end
end

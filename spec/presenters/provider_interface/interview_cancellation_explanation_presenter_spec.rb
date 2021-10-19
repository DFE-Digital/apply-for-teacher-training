require 'rails_helper'

RSpec.describe ProviderInterface::InterviewCancellationExplanationPresenter do
  let(:application_choice) { create(:application_choice) }

  describe 'text' do
    context 'when there is one interview in the future' do
      let!(:interview) { create(:interview, date_and_time: 1.day.from_now, application_choice: application_choice) }

      it 'returns the single interview message' do
        expect(described_class.new(application_choice).text).to eq('The upcoming interview will be cancelled.')
      end
    end

    context 'when there are two or more interviews in the future' do
      let!(:interview) { create(:interview, date_and_time: 3.days.from_now, application_choice: application_choice) }
      let!(:interview_two) { create(:interview, date_and_time: 2.days.from_now, application_choice: application_choice) }

      it 'returns the multiple interviews message' do
        expect(described_class.new(application_choice).text).to eq('Upcoming interviews will be cancelled.')
      end
    end
  end

  describe 'render?' do
    context 'when there is a future interview' do
      let!(:interview) { create(:interview, date_and_time: 1.day.from_now, application_choice: application_choice) }

      it 'returns true' do
        expect(described_class.new(application_choice).render?).to eq(true)
      end
    end

    context 'when there are no future interviews' do
      it 'returns false' do
        expect(described_class.new(application_choice).render?).to eq(false)
      end
    end
  end
end

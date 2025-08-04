require 'rails_helper'

RSpec.describe CandidateMailers::SendDeclinedLastApplicationChoiceEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:decline_last_application_choice).and_return(mail)
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url).and_return(recommended_courses_url)
    end

    let(:recommended_courses_url) { nil }

    it 'sends the decline_last_application_choice email to the candidate' do
      application_choice = create(:application_choice, status: :rejected)

      described_class.new.perform(application_choice.id)

      expect(CandidateCoursesRecommender).to have_received(:recommended_courses_url)
                                               .with(candidate: application_choice.candidate,
                                                     locatable: application_choice.current_provider)
      expect(CandidateMailer).to have_received(:decline_last_application_choice).with(application_choice, nil)
    end

    context 'when recommended courses URL is provided' do
      let(:recommended_courses_url) { 'https://example.com/recommended-courses' }

      it 'sends the decline_last_application_choice email with the recommended courses URL' do
        application_choice = create(:application_choice, status: :rejected)

        described_class.new.perform(application_choice.id)

        expect(CandidateMailer).to have_received(:decline_last_application_choice).with(application_choice, 'https://example.com/recommended-courses')
      end
    end
  end
end

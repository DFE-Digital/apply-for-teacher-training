require 'rails_helper'

RSpec.describe CandidateMailers::SendWithdrawnLastApplicationChoiceEmailWorker do
  describe '#perform' do
    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:withdraw_last_application_choice).and_return(mail)
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url).and_return(recommended_courses_url)
    end

    let(:recommended_courses_url) { nil }

    it 'sends the withdraw_last_application_choice email to the candidate' do
      application_form = create(:completed_application_form)
      create(:application_choice, status: :withdrawn, application_form: application_form)

      described_class.new.perform(application_form.id)

      expect(CandidateCoursesRecommender).to have_received(:recommended_courses_url)
                                               .with(candidate: application_form.candidate,
                                                     locatable: application_form)
      expect(CandidateMailer).to have_received(:withdraw_last_application_choice).with(application_form, nil)
    end

    context 'when recommended courses URL is provided' do
      let(:recommended_courses_url) { 'https://example.com/recommended-courses' }

      it 'sends the withdraw_last_application_choice email with the recommended courses URL' do
        application_form = create(:completed_application_form)
        create(:application_choice, status: :withdrawn, application_form: application_form)

        described_class.new.perform(application_form.id)

        expect(CandidateMailer).to have_received(:withdraw_last_application_choice).with(application_form, 'https://example.com/recommended-courses')
      end
    end
  end
end

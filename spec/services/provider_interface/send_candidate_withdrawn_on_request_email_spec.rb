require 'rails_helper'

RSpec.describe ProviderInterface::SendCandidateWithdrawnOnRequestEmail do
  describe '#call' do
    before do
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url)
                                              .and_return(recommended_courses_url)
      allow(CandidateMailer).to receive(:application_withdrawn_on_request).and_return(
        instance_double(ActionMailer::MessageDelivery, deliver_later: true),
      )
    end

    let(:recommended_courses_url) { nil }

    it 'the application_withdrawn_on_request email is sent to the candidate' do
      application_choice = create(:application_choice)
      described_class.new(application_choice:).call

      expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
                                   .with(application_choice, nil)
    end

    context 'when a course recommendation url can be generated' do
      let(:recommended_courses_url) { 'https://find-teacher-training-courses.service.gov.uk/results' }

      it 'includes the course recommendation URL in the email' do
        application_choice = create(:application_choice)
        described_class.new(application_choice:).call

        expect(CandidateMailer).to have_received(:application_withdrawn_on_request)
                                     .with(
                                       application_choice,
                                       'https://find-teacher-training-courses.service.gov.uk/results',
                                     )
      end
    end
  end
end

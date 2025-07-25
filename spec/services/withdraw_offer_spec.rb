require 'rails_helper'

RSpec.describe WithdrawOffer do
  before do
    allow(CandidateMailer).to receive(:offer_withdrawn).and_return(
      instance_double(ActionMailer::MessageDelivery, deliver_later: true),
    )
    allow(CandidateCoursesRecommender).to receive(:recommended_courses_url)
                                            .and_return(recommended_courses_url)
  end

  let(:recommended_courses_url) { nil }

  describe '#save!' do
    it 'changes the state of the application_choice to "rejected" given a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      withdrawal_reason = 'We are so sorry...'
      described_class.new(
        actor: create(:support_user),
        application_choice:,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(application_choice.reload.status).to eq 'offer_withdrawn'
    end

    it 'does not change the state of the application_choice to "rejected" without a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      service = described_class.new(
        actor: create(:support_user),
        application_choice:,
      )

      expect(service.save).to be false

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'raises an error if the user is not authorised' do
      application_choice = create(:application_choice, status: :offer)
      provider_user = create(:provider_user)
      provider_user.providers << application_choice.current_course.provider

      service = described_class.new(
        actor: provider_user,
        application_choice:,
        offer_withdrawal_reason: 'We are so sorry...',
      )

      expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'sends an email to the candidate' do
      application_choice = create(:application_choice, status: :offer)
      withdrawal_reason = 'We messed up big time'

      described_class.new(
        actor: create(:support_user),
        application_choice:,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(CandidateMailer).to have_received(:offer_withdrawn)
                                   .with(application_choice, nil)
    end

    context 'with a course recommendation url' do
      let(:recommended_courses_url) { 'https://www.find-postgraduate-teacher-training.service.gov.uk/results' }

      it 'sends an email to the candidate with a recommendation url' do
        application_choice = create(:application_choice, status: :offer)
        withdrawal_reason = 'We messed up big time'

        described_class.new(
          actor: create(:support_user),
          application_choice:,
          offer_withdrawal_reason: withdrawal_reason,
        ).save

        expect(CandidateMailer).to have_received(:offer_withdrawn)
                                     .with(application_choice, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe UpdateDuplicateMatches, sidekiq: true do
  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }

  let(:expected_slack_message) do
    <<~MSG
      \n#{Rails.application.routes.url_helpers.support_interface_fraud_auditing_matches_url}
      :face_with_monocle: There is 1 new duplicate candidate match today :face_with_monocle:
      :gavel: 1 match has been marked as fraudulent :gavel:
      :female-detective: In total there are 2 matches :male-detective:
    MSG
  end

  before do
    Timecop.freeze(Time.zone.local(2020, 8, 23, 12, 0o0, 0o0)) do
      create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
      create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
      allow(SlackNotificationWorker).to receive(:perform_async)
    end
  end

  describe '#save!' do
    context 'when there is no fraud match for the given candidates' do
      it 'creates a fraud match with associated candidates' do
        described_class.new.save!

        match = FraudMatch.first

        expect(match.postcode).to eq('W6 9BH')
        expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
        expect(match.last_name).to eq('Thompson')
        expect(match.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
        expect(match.candidates.first).to eq(candidate1)
        expect(match.candidates.second).to eq(candidate2)
      end

      it 'sets `Candidate#submission_blocked` to true' do
        described_class.new.save!
        expect(candidate1.reload.submission_blocked).to be(true)
        expect(candidate2.reload.submission_blocked).to be(true)
      end

      it 'sends an email to each candidate' do
        expect { described_class.new.save! }.to change { ActionMailer::Base.deliveries.count }.by(2)
        # TODO:
      end

      it 'sends a slack message' do
        application_form1 = create(:application_form, first_name: 'Jeffrey', last_name: 'Thompsun', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
        application_form2 = create(:application_form, first_name: 'Joffrey', last_name: 'Thompsun', date_of_birth: '1998-08-08', postcode: 'W6 9BH')

        create(:fraud_match,
               candidates: [application_form1.candidate, application_form2.candidate],
               last_name: 'Thompsun',
               date_of_birth: '1998-08-08',
               postcode: 'W6 9BH',
               fraudulent: true,
               created_at: 2.days.ago)

        described_class.new.save!

        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_slack_message)
      end
    end

    context 'when a fraud match exists for the given candidates' do
      it 'updates an existing fraud match with new candidate' do
        described_class.new.save!

        match = FraudMatch.first
        expect(match.candidates.third).to eq(nil)

        create(:application_form, candidate: create(:candidate, email_address: 'exemplar3@example.com'), first_name: 'Jaffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
        described_class.new.save!

        match = FraudMatch.first

        expect(match.candidates.third.email_address).to eq('exemplar3@example.com')

        expect(match.postcode).to eq('W6 9BH')
        expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
        expect(match.last_name).to eq('Thompson')
        expect(match.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
      end

      it 'sets `Candidate#submission_blocked` to true' do
        described_class.new.save!
        expect(candidate1.reload.submission_blocked).to be(true)
        expect(candidate2.reload.submission_blocked).to be(true)
      end

      it 'sends an email to each candidate' do
        expect { described_class.new.save! }.to change { ActionMailer::Base.deliveries.count }.by(2)
        # TODO:
      end
    end
  end
end

require 'rails_helper'

RSpec.describe UpdateDuplicateMatches, :sidekiq do
  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }

  let(:expected_slack_message) do
    <<~MSG
      \n#{Rails.application.routes.url_helpers.support_interface_duplicate_matches_url}
      :face_with_monocle: There is 1 new duplicate candidate match today :face_with_monocle:
      :female-detective: In total there are 2 matches :male-detective:
    MSG
  end

  before do
    travel_temporarily_to(Time.zone.local(2020, 8, 23, 12)) do
      create(:application_form, :duplicate_candidates, candidate: candidate1, submitted_at: Time.zone.now)
      create(:application_form, :duplicate_candidates, candidate: candidate2)
      allow(SlackNotificationWorker).to receive(:perform_async)
    end
  end

  describe '#save!' do
    context 'when notify_slack_at is not set' do
      it 'notifies slack' do
        described_class.new.save!
        expect(SlackNotificationWorker).to have_received(:perform_async)
      end
    end

    context 'when notify_slack_at is set, but at a different time' do
      it 'does not notify slack' do
        travel_temporarily_to(Time.zone.local(2020, 8, 23, 10)) do
          described_class.new(notify_slack_at: 13).save!
        end

        expect(SlackNotificationWorker).not_to have_received(:perform_async)
      end
    end

    context 'when notify_slack_at is set, at the same time' do
      it 'notifies slack' do
        travel_temporarily_to(Time.zone.local(2020, 8, 23, 10)) do
          described_class.new(notify_slack_at: 10).save!
        end

        expect(SlackNotificationWorker).to have_received(:perform_async)
      end
    end

    context 'when existing duplicate match' do
      before do
        described_class.new.save!
      end

      context 'when the candidates have been manually unblocked' do
        before do
          candidate1.reload.update!(submission_blocked: false)
          candidate2.reload.update!(submission_blocked: false)
          described_class.new.save!
        end

        it 'do not mark submission blocked if candidate is not newly added to the match' do
          expect(candidate1.reload.submission_blocked).to be(false)
          expect(candidate2.reload.submission_blocked).to be(false)
        end
      end

      context 'when a duplicate match has been manually resolved and a new candidate is added to the match' do
        let(:candidate3) { create(:candidate, email_address: 'exemplar3@example.com') }

        before do
          DuplicateMatch.first.update(resolved: true)
          create(:application_form, :duplicate_candidates, candidate: candidate3)
          described_class.new.save!
        end

        it 'marks the match as unresolved' do
          expect(DuplicateMatch.first).not_to be_resolved
        end
      end
    end

    context 'when there is no duplicate match for the given candidates' do
      it 'creates a duplicate match with associated candidates' do
        described_class.new.save!

        match = DuplicateMatch.first

        expect(match.postcode).to eq('W6 9BH')
        expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
        expect(match.last_name).to eq('Thompson')
        expect(match.recruitment_cycle_year).to eq(current_year)
        expect(match.candidates.first).to eq(candidate1)
        expect(match.candidates.second).to eq(candidate2)
      end

      it 'sets `Candidate#submission_blocked` to true' do
        described_class.new.save!
        expect(candidate1.reload.submission_blocked).to be(true)
        expect(candidate2.reload.submission_blocked).to be(true)
      end

      it 'sends a slack message' do
        application_form1 = create(:application_form, :duplicate_candidates, submitted_at: Time.zone.now)
        application_form2 = create(:application_form, :duplicate_candidates)

        create(:duplicate_match,
               candidates: [application_form1.candidate, application_form2.candidate],
               last_name: 'Thompsun',
               date_of_birth: '1998-08-08',
               postcode: 'W6 9BH',
               created_at: 2.days.ago)

        described_class.new.save!

        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_slack_message)
      end
    end

    context 'when a duplicate match exists for the given candidates' do
      it 'updates an existing duplicate match with new candidate' do
        described_class.new.save!

        match = DuplicateMatch.first
        expect(match.candidates.third).to be_nil

        create(:application_form, :duplicate_candidates, candidate: create(:candidate, email_address: 'exemplar3@example.com'))
        described_class.new.save!

        match = DuplicateMatch.first

        expect(match.candidates.count).to be(3)
        expect(match.candidates.third.email_address).to eq('exemplar3@example.com')

        expect(match.postcode).to eq('W6 9BH')
        expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
        expect(match.last_name).to eq('Thompson')
        expect(match.recruitment_cycle_year).to eq(current_year)
      end

      it 'sets `Candidate#submission_blocked` to true' do
        described_class.new.save!
        expect(candidate1.reload.submission_blocked).to be(true)
        expect(candidate2.reload.submission_blocked).to be(true)
      end

      it 'sends email to candidate from a new match or newly candidate to an existing match' do
        expect { 2.times { described_class.new.save! } }.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(ActionMailer::Base.deliveries.map(&:to)).to contain_exactly(
          ['exemplar1@example.com'],
          ['exemplar2@example.com'],
        )
      end
    end

    context 'when a duplicate match exists with postcode and last name that differ only by whitespace and case' do
      it 'updates an existing duplicate match with new candidate' do
        described_class.new.save!

        match = DuplicateMatch.first
        expect(match.candidates.third).to be_nil

        create(
          :application_form,
          :duplicate_candidates,
          last_name: " #{ApplicationForm.last.last_name.upcase} ",
          postcode: "#{ApplicationForm.last.postcode.downcase} ",
          candidate: create(:candidate, email_address: 'exemplar3@example.com'),
        )
        described_class.new.save!

        match = DuplicateMatch.first

        expect(match.candidates.count).to be(3)
        expect(match.candidates.third.email_address).to eq('exemplar3@example.com')

        expect(match.postcode).to eq('W6 9BH')
        expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
        expect(match.last_name).to eq('Thompson')
        expect(match.recruitment_cycle_year).to eq(current_year)
      end
    end

    context 'when last name, date of birth matches and postcode is nil' do
      before do
        ApplicationForm.update_all(postcode: nil)
      end

      it 'saves one duplicate match' do
        described_class.new.save!
        expect(DuplicateMatch.count).to be(1)
      end
    end

    context 'when send email is manually set to false' do
      it 'does not send the email' do
        described_class.new(send_email: false).save!
        expect(ActionMailer::Base.deliveries.map(&:to)).not_to contain_exactly(
          ['exemplar1@example.com'],
          ['exemplar2@example.com'],
        )
      end
    end

    context 'when block submission is manually set to false' do
      it 'does not block submission' do
        described_class.new(block_submission: false).save!
        expect(candidate1.reload.submission_blocked).to be(false)
        expect(candidate2.reload.submission_blocked).to be(false)
      end
    end
  end
end

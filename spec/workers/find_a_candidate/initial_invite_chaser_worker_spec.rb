require 'rails_helper'

module FindACandidate
  RSpec.describe InitialInviteChaserWorker do
    describe '#perform' do
      context 'without chasers and invites not over limit' do
        it 'enqueues chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 4.days.ago,
            application_form:,
          )
          second_application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 3.days.ago - 1.hour,
            application_form: second_application_form,
          )
          recent_application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 2.days.ago,
            application_form: recent_application_form,
          )
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).to have_received(:perform_later).twice
        end
      end

      context 'with chasers and invites over limit' do
        it 'enqueues chaser worker' do
          application_form = create(:application_form, :completed)
          _invite = create(:pool_invite, :sent_to_candidate, sent_to_candidate_at: 4.days.ago)
          _limit_reached_invite_1 = create(:pool_invite, :sent_to_candidate, application_form:, sent_to_candidate_at: 4.days.ago)
          _limit_reached_invite_2 = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 4.days.ago,
            application_form:,
          )
          chaser_send_invite = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
          )
          create(:chaser_sent, chased: chaser_send_invite, chaser_type: 'initial_pool_invite')
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).to have_received(:perform_later).once
        end
      end

      context 'with chasers and no new invites' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          invite = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 4.days.ago,
            application_form:,
          )

          create(:chaser_sent, chased: invite, chaser_type: 'initial_pool_invite')
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).not_to have_received(:perform_later)
        end
      end

      context 'without chasers but invites in previous cycle' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 4.days.ago,
            application_form:,
            recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
          )
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 4.days.ago,
            application_form:,
            recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
          )
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).not_to have_received(:perform_later)
        end
      end

      context 'without chasers but invites not published' do
        it 'does not enqueue chaser worker' do
          create(:pool_invite, sent_to_candidate_at: 4.days.ago)
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).not_to have_received(:perform_later)
        end
      end

      context 'without chasers but invites already responded' do
        it 'does not enqueue chaser worker' do
          create(
            :pool_invite,
            candidate_decision: 'accepted',
            sent_to_candidate_at: 4.days.ago,
          )
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).not_to have_received(:perform_later)
        end
      end

      context 'without chasers but invites are not old enough' do
        it 'does not enqueue chaser worker' do
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 2.hours.ago,
          )
          allow(SendInitialChaserWorker).to receive(:perform_later)

          described_class.new.perform

          expect(SendInitialChaserWorker).not_to have_received(:perform_later)
        end
      end
    end
  end
end

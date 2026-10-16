require 'rails_helper'

module FindACandidate
  RSpec.describe PoolInviteChaserWorker do
    describe '#perform' do
      context 'without chasers and invites over limit' do
        it 'enqueues chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.days.ago,
            application_form:,
          )
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.days.ago,
            application_form:,
          )
          second_application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form: second_application_form,
          )
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form: second_application_form,
          )
          described_class.new.perform

          expect(SendChaserWorker).to have_been_enqueued.twice
        end
      end

      context 'with chasers and new invites over limit' do
        it 'enqueues chaser worker' do
          application_form = create(:application_form, :completed)
          invite_1 = create(:pool_invite, :sent_to_candidate, application_form:)
          invite_2 = create(:pool_invite, :sent_to_candidate, application_form:)
          _invite_3 = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
          )
          _invite_4 = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
          )
          create(:chaser_sent, chased: invite_1, chaser_type: 'pool_invite')
          create(:chaser_sent, chased: invite_2, chaser_type: 'pool_invite')
          described_class.new.perform

          expect(SendChaserWorker).to have_been_enqueued.once
        end
      end

      context 'with chasers and no new invites' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          invite_1 = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
          )
          invite_2 = create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
          )

          create(:chaser_sent, chased: invite_1, chaser_type: 'pool_invite')
          create(:chaser_sent, chased: invite_2, chaser_type: 'pool_invite')
          described_class.new.perform

          expect(SendChaserWorker).not_to have_been_enqueued
        end
      end

      context 'without chasers but invites in previous cycle' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
            recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
          )
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
            recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
          )
          described_class.new.perform

          expect(SendChaserWorker).not_to have_been_enqueued
        end
      end

      context 'without chasers but invites not published' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          create(:pool_invite, application_form:)
          create(:pool_invite, application_form:)
          described_class.new.perform

          expect(SendChaserWorker).not_to have_been_enqueued
        end
      end

      context 'without chasers but invites already responded' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            application_form:,
            candidate_decision: 'accepted',
            sent_to_candidate_at: 25.hours.ago,
          )
          create(
            :pool_invite,
            application_form:,
            candidate_decision: 'accepted',
            sent_to_candidate_at: 25.hours.ago,
          )
          described_class.new.perform

          expect(SendChaserWorker).not_to have_been_enqueued
        end
      end

      context 'without chasers but invites are not old enough' do
        it 'does not enqueue chaser worker' do
          application_form = create(:application_form, :completed)
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 2.hours.ago,
            application_form:,
          )
          create(
            :pool_invite,
            status: 'published',
            sent_to_candidate_at: 25.hours.ago,
            application_form:,
          )
          described_class.new.perform

          expect(SendChaserWorker).not_to have_been_enqueued
        end
      end
    end
  end
end

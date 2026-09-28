require 'rails_helper'

RSpec.describe FindACandidate::SendInitialChaserWorker do
  describe '#perform' do
    context 'without chasers' do
      it 'creates chasers' do
        invite = create(:pool_invite, :sent_to_candidate)
        create(:candidate_preference, application_form: invite.candidate.current_application)

        expect {
          described_class.new.perform(invite.id)
        }.to(change { ChaserSent.count }.from(0).to(1))
      end
    end

    context 'with_chasers' do
      it 'does not creates chasers' do
        invite = create(:pool_invite, :sent_to_candidate)
        create(:chaser_sent, chased: invite, chaser_type: 'initial_pool_invite')

        expect {
          described_class.new.perform(invite.id)
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but not current_cycle' do
      it 'does not creates chasers' do
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
        )

        expect {
          described_class.new.perform(invite.id)
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but invites not published' do
      it 'does not creates chasers' do
        invite = create(:pool_invite)

        expect {
          described_class.new.perform(invite.id)
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but invites responded' do
      it 'does not creates chasers' do
        invite = create(:pool_invite, candidate_decision: 'accepted')

        expect {
          described_class.new.perform(invite.id)
        }.not_to(change { ChaserSent.count })
      end
    end
  end
end

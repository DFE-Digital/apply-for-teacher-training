require 'rails_helper'

RSpec.describe FindACandidate::SendChaserWorker do
  describe '#perform' do
    context 'without chasers' do
      it 'creates chasers' do
        invite_1 = create(:pool_invite, :sent_to_candidate)
        invite_2 = create(:pool_invite, :sent_to_candidate)

        expect {
          described_class.new.perform([invite_1.id, invite_2.id])
        }.to(change { ChaserSent.count }.from(0).to(2))
      end
    end

    context 'with_chasers' do
      it 'does not creates chasers' do
        invite_1 = create(:pool_invite, :sent_to_candidate)
        invite_2 = create(:pool_invite, :sent_to_candidate)
        create(:chaser_sent, chased: invite_1, chaser_type: 'pool_invite')
        create(:chaser_sent, chased: invite_2, chaser_type: 'pool_invite')

        expect {
          described_class.new.perform([invite_1.id, invite_2.id])
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but not current_cycle' do
      it 'does not creates chasers' do
        invite_1 = create(
          :pool_invite,
          :sent_to_candidate,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
        )
        invite_2 = create(
          :pool_invite,
          :sent_to_candidate,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
        )

        expect {
          described_class.new.perform([invite_1.id, invite_2.id])
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but invites not published' do
      it 'does not creates chasers' do
        invite_1 = create(:pool_invite)
        invite_2 = create(:pool_invite)

        expect {
          described_class.new.perform([invite_1.id, invite_2.id])
        }.not_to(change { ChaserSent.count })
      end
    end

    context 'without chasers but invites responded' do
      it 'does not creates chasers' do
        invite_1 = create(:pool_invite, candidate_decision: 'applied')
        invite_2 = create(:pool_invite, candidate_decision: 'applied')

        expect {
          described_class.new.perform([invite_1.id, invite_2.id])
        }.not_to(change { ChaserSent.count })
      end
    end
  end
end

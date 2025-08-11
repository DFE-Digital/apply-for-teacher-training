require 'rails_helper'

RSpec.describe EndOfCycle::CancelPendingInvitesWorker do
  describe '#perform' do
    context 'when force is true', time: mid_cycle do
      it 'sets the published not_responded invites to cancelled' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(true) }.to change { not_responded.reload.status }
          .from('published').to('cancelled')
          .and(not_change { accepted.reload.status })
          .and(not_change { declined.reload.status })
          .and(not_change { draft.reload.status })
      end
    end

    context 'when force is false', time: mid_cycle do
      it 'does not set the published not_responded invites to cancelled' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(false) }.to not_change { not_responded.reload.status }
          .and not_change { accepted.reload.status }
          .and not_change { declined.reload.status }
          .and(not_change { draft.reload.status })
      end
    end

    context 'when force is true', time: after_apply_deadline do
      it 'sets the published not_responded invites to cancelled' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(true) }.to change { not_responded.reload.status }
          .from('published').to('cancelled')
          .and(not_change { accepted.reload.status })
          .and(not_change { declined.reload.status })
          .and(not_change { draft.reload.status })
      end
    end
  end
end

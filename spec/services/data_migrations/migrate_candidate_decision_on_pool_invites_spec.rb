require 'rails_helper'

RSpec.describe DataMigrations::MigrateCandidateDecisionOnPoolInvites do
  describe '#change' do
    it 'updates all the applied candidate_decisions to accepted' do
      applied_invite = create(:pool_invite, candidate_decision: 'applied')
      published_applied_invite = create(:pool_invite, :sent_to_candidate, candidate_decision: 'applied')
      not_responded_invite = create(:pool_invite, candidate_decision: 'not_responded')
      declined_invite = create(:pool_invite, candidate_decision: 'declined')

      expect { described_class.new.change }
        .to change { applied_invite.reload.candidate_decision }.from('applied').to('accepted')
        .and change { published_applied_invite.reload.candidate_decision }.from('applied').to('accepted')
        .and not_change { not_responded_invite.reload.candidate_decision }
        .and(not_change { declined_invite.reload.candidate_decision })
    end
  end
end

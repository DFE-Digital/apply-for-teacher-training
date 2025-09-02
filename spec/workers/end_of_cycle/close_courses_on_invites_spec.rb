require 'rails_helper'

RSpec.describe EndOfCycle::CloseCoursesOnInvites do
  describe '#perform' do
    context 'when force is true', time: mid_cycle do
      it 'closes the courses on published invites' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(true) }.to change { not_responded.reload.course_open }
          .from(true).to(false)
          .and(change { accepted.reload.course_open }.from(true).to(false))
          .and(change { declined.reload.course_open }.from(true).to(false))
          .and(not_change { draft.reload.course_open })
      end
    end

    context 'when force is false mid cycle', time: mid_cycle do
      it 'does not close the courses on published invites' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(false) }.to not_change { not_responded.reload.course_open }
          .and not_change { accepted.reload.course_open }
          .and not_change { declined.reload.course_open }
          .and(not_change { draft.reload.course_open })
      end
    end

    context 'when force is false on application_deadline', time: cancel_application_deadline do
      it 'closes the courses on published invites' do
        not_responded = create(:pool_invite, :sent_to_candidate)
        accepted = create(:pool_invite, :sent_to_candidate, candidate_decision: 'accepted')
        declined = create(:pool_invite, :sent_to_candidate, candidate_decision: 'declined')
        draft = create(:pool_invite)

        expect { described_class.new.perform(false) }.to change { not_responded.reload.course_open }
          .from(true).to(false)
          .and(change { accepted.reload.course_open }.from(true).to(false))
          .and(change { declined.reload.course_open }.from(true).to(false))
          .and(not_change { draft.reload.status })
      end
    end
  end
end

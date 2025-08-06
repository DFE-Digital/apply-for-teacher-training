require 'rails_helper'

RSpec.describe CandidateInterface::InviteApplication do
  let(:application_form) { create(:application_form, :completed) }
  let(:application_choice) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      application_form:,
    )
  end
  let!(:invite) {
    create(
      :pool_invite,
      :sent_to_candidate,
      application_form:,
      course: application_choice.course,
    )
  }

  describe '.accepted' do
    context 'when accepted invited course' do
      it 'saves applied state on invite' do
        described_class.accepted!(application_form:, application_choice:)

        expect(invite.reload.application_choice_id).to eq(application_choice.id)
        expect(invite.reload.accepted?).to be(true)
      end
    end

    context 'when application_choice has changed course to a non invited course including the original one' do
      let!(:invite) {
        create(
          :pool_invite,
          :sent_to_candidate,
          application_form:,
          application_choice:,
          candidate_decision: 'accepted',
        )
      }

      it 'removes the link between the choice and the invite' do
        described_class.accepted!(application_form:, application_choice:)

        expect(invite.reload.application_choice_id).to be_nil
        expect(invite.reload.accepted?).to be(false)
      end
    end

    context 'when application_choice has changed course to a non invited course but the original one is an invited one' do
      let(:original_course) { create(:course) }
      let(:application_choice) do
        create(
          :application_choice,
          :awaiting_provider_decision,
          application_form:,
          course: create(:course),
          original_course: original_course,
        )
      end

      let!(:invite) {
        create(
          :pool_invite,
          :sent_to_candidate,
          application_form:,
          application_choice:,
          course: original_course,
          candidate_decision: 'accepted',
        )
      }

      it 'removes the link between the choice and the invite' do
        described_class.accepted!(application_form:, application_choice:)

        expect(invite.reload.application_choice_id).to eq(application_choice.id)
        expect(invite.reload.accepted?).to be(true)
      end
    end
  end

  describe '.accept_and_link_to_choice!' do
    it 'accepts the invite and links the invite to a choice' do
      described_class.accept_and_link_to_choice!(application_choice:, invite:)

      expect(invite.reload.application_choice_id).to eq(application_choice.id)
      expect(invite.reload.accepted?).to be(true)
    end
  end

  describe '.unlink_invites_from_choice!' do
    let!(:invite) {
      create(
        :pool_invite,
        :sent_to_candidate,
        application_form:,
        application_choice:,
      )
    }

    it 'removed chice from invite and sets it to not_responded' do
      described_class.unlink_invites_from_choice(application_choice:)

      expect(invite.reload.application_choice_id).to be_nil
      expect(invite.reload.not_responded?).to be(true)
    end
  end
end

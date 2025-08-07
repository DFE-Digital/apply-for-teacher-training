require 'rails_helper'

RSpec.describe CandidateInterface::DeleteApplicationChoice do
  describe '#call' do
    context 'when an application form has only one application choice' do
      it 'deletes the given application choice and resets `course_choices_completed`' do
        application_form = create(:application_form, course_choices_completed: true)
        application_choice = create(:application_choice, application_form:)
        invite = create(
          :pool_invite,
          :sent_to_candidate,
          candidate_decision: 'accepted',
          application_choice:,
        )

        expect { described_class.new(application_choice:).call }
          .to change { invite.reload.application_choice_id }.from(application_choice.id).to(nil)
          .and change { invite.reload.candidate_decision }.from('accepted').to('not_responded')
        expect(application_form.reload.application_choices).to be_empty
        expect(application_form.course_choices_completed).to be_nil
      end
    end

    context 'when an application form has multiple application choices' do
      it 'deletes the only the given application choice and leaves `course_choices_completed` as true' do
        application_form = create(:application_form, course_choices_completed: true)
        create(:application_choice, application_form:)
        application_choice = create(:application_choice, application_form:)

        described_class.new(application_choice:).call
        expect(application_choice.destroyed?).to be(true)
        expect(application_form.reload.application_choices.count).to be(1)
        expect(application_form.course_choices_completed).to be(true)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::FacInviteResponseForm, type: :model do
  include Rails.application.routes.url_helpers

  subject(:form) do
    described_class.new(invite:, apply_for_this_course:)
  end

  let(:invite) { create(:pool_invite, :sent_to_candidate, course: course_option.course) }
  let(:course_option) { create(:course_option) }
  let(:apply_for_this_course) { 'yes' }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:apply_for_this_course) }
  end

  describe '#path_to_redirect' do
    context 'with draft_application for the same course as invite and apply_for_this_course is yes' do
      it 'redirect to draft application choice' do
        draft_choice = create(
          :application_choice,
          application_form: invite.application_form,
          course_option: invite.course.course_options.first,
        )

        expect(form.path_to_redirect).to eq(
          candidate_interface_course_choices_course_review_path(
            draft_choice,
            return_to: 'invite',
          ),
        )
      end
    end

    context 'with no draft_application and apply_for_this_course is yes' do
      it 'redirect to course selection' do
        expect(form.path_to_redirect).to eq(
          candidate_interface_course_choices_course_confirm_selection_path(invite.course),
        )
      end
    end

    context 'when apply_for_this_course is no' do
      let(:apply_for_this_course) { 'no' }

      it 'redirect to decline reason' do
        expect(form.path_to_redirect).to eq(
          new_candidate_interface_invite_decline_reason_path(invite),
        )
      end
    end
  end
end

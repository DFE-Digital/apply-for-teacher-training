require 'rails_helper'

RSpec.describe CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent do
  include Rails.application.routes.url_helpers

  it 'renders the component with the invite' do
    course = build_stubbed(:course)
    invite = build_stubbed(:pool_invite, course:)

    result = render_inline(described_class.new(invite:))

    expect(result).to have_text('If you have changed your mind you can still apply to this course')
    expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course))
  end

  context 'when the invite has been declined with a only_salaried reason' do
    it 'renders with the change funding preferences message' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate:)
      invite = create(:pool_invite, application_form: application_form)

      allow(invite).to receive(:decline_reasons_include_only_salaried?).and_return(true)

      result = render_inline(described_class.new(invite:))

      expect(result).to have_text('Change your funding preferences to receive invitations to more relevant courses')
      expect(result).to have_link('Change your funding preferences', href: candidate_interface_candidate_preferences_path(candidate))

      expect(result).to have_text('If you have changed your mind you can still apply to this course')
      expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(invite.course))
    end
  end
end

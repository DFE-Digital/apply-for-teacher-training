require 'rails_helper'

RSpec.describe CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent do
  include Rails.application.routes.url_helpers

  it 'renders with the change location preferences message' do
    course = build_stubbed(:course)
    invite = build_stubbed(:pool_invite, course:)

    component = described_class.new(invite:)
    result = render_inline(component)

    expect(result).to have_text('Update your location preferences to receive invitations to more relevant courses')
    expect(result).to have_link('Update your location preferences', href: component.candidate_interface_candidate_preferences_review_path)

    expect(result).to have_text('If you have changed your mind you can still apply to this course')
    expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course))
  end

  context 'when the candidate has opted in and has set a funding type' do
    it 'renders with the change location preferences and funding message' do
      application_form = build_stubbed(:application_form, published_preference: build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary'))
      course = build_stubbed(:course)
      invite = build_stubbed(:pool_invite, application_form:, course:)

      component = described_class.new(invite:)
      result = render_inline(component)

      expect(result).to have_text('Update your location and funding preferences to receive invitations to more relevant courses')
      expect(result).to have_link('Update your location and funding preferences', href: component.candidate_interface_candidate_preferences_review_path)

      expect(result).to have_text('If you have changed your mind you can still apply to this course')
      expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course))
    end
  end
end

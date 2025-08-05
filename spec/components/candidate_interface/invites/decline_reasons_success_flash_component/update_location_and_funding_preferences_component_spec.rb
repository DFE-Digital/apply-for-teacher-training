require 'rails_helper'

RSpec.describe CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::UpdateLocationAndFundingPreferencesComponent do
  include Rails.application.routes.url_helpers

  it 'renders with the change location preferences and funding message' do
    candidate = build_stubbed(:candidate)
    course = build_stubbed(:course)
    invite = build_stubbed(:pool_invite, candidate:, course:)

    result = render_inline(described_class.new(invite:))

    expect(result).to have_text('Update your location and funding preferences to receive invitations to more relevant courses')
    expect(result).to have_link('Update your location and funding preferences', href: candidate_interface_candidate_preferences_path(candidate))

    expect(result).to have_text('If you have changed your mind you can still apply to this course')
    expect(result).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course))
  end
end

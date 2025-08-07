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
end

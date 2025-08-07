require 'rails_helper'

RSpec.describe 'Candidate tries to submit an application choice when the course is closed' do
  include SignInHelper
  include CandidateHelper

  before do
    given_i_am_signed_in
    and_i_have_one_application_in_draft
  end

  scenario 'Apply is closed', time: after_find_opens do
    when_i_continue_my_draft_application
    then_i_see_the_course_closed_error_message_until_apply_opens
  end

  scenario 'Apply is open', time: mid_cycle do
    when_i_continue_my_draft_application
    then_i_do_not_see_any_error_message
    and_i_can_review_my_application
  end

  def then_i_see_the_course_closed_error_message_until_apply_opens
    expect(page).to have_content(
      "This course is not yet open to applications. You will be able to submit your application on #{apply_opens_at.to_fs(:govuk_date)}.",
    )
    expect(page).to have_no_content('Review application')
  end

  def then_i_do_not_see_any_error_message
    expect(page).to have_no_content('This course is not yet open to applications.')
  end

  def and_i_can_review_my_application
    expect(page).to have_content('Review application')
  end

  def apply_opens_at
    @apply_opens_at ||= current_timetable.apply_opens_at
  end
end

require 'rails_helper'

RSpec.describe 'Viewing application details between cycles' do
  include CandidateHelper

  scenario 'Candidate has an inflight application', time: mid_cycle do
    given_i_have_an_inflight_application
    and_the_apply_deadline_passes
    when_i_view_the_application_details_page
    then_i_am_not_prompted_to_add_applications
  end

private

  def given_i_have_an_inflight_application
    @application_form = create(:application_form, :completed, submitted_application_choices_count: 1)
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def when_i_view_the_application_details_page
    login_as(current_candidate)
    visit root_path
    click_on 'Your details'
  end

  def then_i_am_not_prompted_to_add_applications
    expect(page).to have_text('Your details')
    expect(page).to have_no_text('You can add your applications.')
    expect(page).to have_no_text('You can now start applying to courses.')
  end
end

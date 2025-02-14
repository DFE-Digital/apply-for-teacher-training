require 'rails_helper'

RSpec.describe 'Cycle switching' do
  include DfESignInHelpers
  let(:timetable) { RecruitmentCycleTimetable.current_timetable }

  scenario 'Support user switches cycle schedule' do
    given_it_is_before_the_apply_deadline
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_cycle_page
    and_i_see_a_mid_cycle_description_and_content

    when_i_update_the_current_cycle_so_the_deadline_has_passed
    then_i_see_post_deadline_description
  end

private

  def given_it_is_before_the_apply_deadline
    TestSuiteTimeMachine.travel_permanently_to(timetable.apply_deadline_at - 13.weeks)
  end

  def when_i_navigate_to_the_cycle_page
    click_on 'Settings'
    click_on 'Recruitment cycles'
  end

  def and_i_see_a_mid_cycle_description_and_content
    expect(page).to have_content "Apply has opened (#{timetable.recruitment_cycle_year})"
    expect(page).to have_content 'Candidates can make choices and submit applications, providers can act on applications.'
  end

  def when_i_update_the_current_cycle_so_the_deadline_has_passed
    click_on timetable.recruitment_cycle_year
    within_fieldset 'Apply deadline' do
      new_date = 1.day.ago
      fill_in 'Day', with: new_date.day
      fill_in 'Month', with: new_date.month
      fill_in 'Year', with: new_date.year
    end
    click_on 'Update'
  end

  def then_i_see_post_deadline_description
    expect(page).to have_content 'The cycle has been updated.'
    expect(page).to have_content "Apply deadline has passed (#{timetable.recruitment_cycle_year})"
    expect(page).to have_content 'The deadline for submitting applications has passed. Candidates without active applications can start preparing applications for next year. Providers can still act on submitted applications.'
  end
end

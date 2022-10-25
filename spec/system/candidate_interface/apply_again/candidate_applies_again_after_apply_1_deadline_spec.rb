require 'rails_helper'

RSpec.describe 'Apply again' do
  include CycleTimetableHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
  end

  scenario 'Candidate applies again after apply 1 deadline' do
    given_i_am_signed_in
    and_i_have_an_application_with_a_rejection

    when_the_apply1_deadline_passes
    and_i_visit_my_application_complete_page
    then_i_should_see_the_apply_again_banner
    and_i_should_see_the_deadline_banner

    when_i_click_apply_again
    then_i_can_see_application_details
    and_i_can_add_course_choices
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :with_rejection, application_form: @application_form)
  end

  def when_the_apply1_deadline_passes
    TestSuiteTimeMachine.advance_time_to(after_apply_1_deadline)
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_should_see_the_apply_again_banner
    expect(page).to have_content 'If now’s the right time for you, you can still apply for courses that start this academic year.'
  end

  def and_i_should_see_the_deadline_banner
    year_range = CycleTimetable.cycle_year_range
    deadline_date = CycleTimetable.date(:apply_2_deadline).to_fs(:govuk_date)
    deadline_time = CycleTimetable.date(:apply_2_deadline).to_fs(:govuk_time)

    expect(page).to have_content("The deadline for applying to courses starting in the #{year_range} academic year is #{deadline_time} on #{deadline_date}")
  end

  def when_i_click_apply_again
    click_button 'Apply again'
  end

  def then_i_can_see_application_details
    expect(page).to have_content('Personal information Completed')
    click_link 'Personal information'
    expect(page).to have_content(@application_form.full_name)
    click_button t('continue')
  end

  def and_i_can_add_course_choices
    expect(page).to have_content('Choose your courses Incomplete')
    expect(page).to have_content 'You can apply for up to 3 courses.'
  end
end

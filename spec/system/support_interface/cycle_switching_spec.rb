require 'rails_helper'

RSpec.feature 'Cycle switching' do
  include DfESignInHelpers

  scenario 'Support user switches cycle schedule' do
    given_i_am_a_support_user
    when_i_click_on_the_recruitment_cycle_link
    then_i_see_the_cycle_information

    when_i_click_to_choose_a_new_schedule
    then_the_schedule_is_updated
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_click_on_the_recruitment_cycle_link
    click_on 'Recruitment cycles'
  end

  def then_i_see_the_cycle_information
    expect(page).to have_title 'Recruitment cycles'
    expect(page).to have_content('This environment is currently on the ‘Real’ schedule')
    expect(page).to have_content("Find closes on\n19 September 2020")
  end

  def when_i_click_to_choose_a_new_schedule
    click_button 'Switch to the ‘Today is after apply 1 deadline passed’ schedule'
  end

  def then_the_schedule_is_updated
    expect(page).to have_content('This environment is currently on the ‘Today is after apply 1 deadline passed’ schedule')
    expect(page).to have_content("Appy 1 deadline\n31 December 2019")
  end
end

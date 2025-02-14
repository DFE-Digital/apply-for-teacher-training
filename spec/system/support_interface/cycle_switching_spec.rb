require 'rails_helper'

RSpec.describe 'Cycle switching' do
  include DfESignInHelpers

  scenario 'Support user switches cycle schedule', skip: 'Reimplement when cycle switcher is working again' do
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
    click_link_or_button 'Settings'
    click_link_or_button 'Recruitment cycles'
  end

  def then_i_see_the_cycle_information
    expect(page).to have_title 'Recruitment cycles'
    expect(page).to have_content("Find closes on #{CycleTimetable.find_closes.to_fs(:govuk_date)}")
  end

  def when_i_click_to_choose_a_new_schedule
    choose 'Apply deadline has passed'
    click_link_or_button 'Update point in recruitment cycle'
  end

  def then_the_schedule_is_updated
    expect(page).to have_content("Apply deadline #{CycleTimetable.apply_deadline.to_fs(:govuk_date)}")
  end
end

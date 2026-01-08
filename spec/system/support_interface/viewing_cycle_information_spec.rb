require 'rails_helper'

RSpec.describe 'Viewing cycle information' do
  include DfESignInHelpers

  context 'Environment is not production' do
    scenario 'viewing cycle information when not in production', time: mid_cycle do
      given_i_am_signed_in_as_a_support_user
      when_i_click_on_the_recruitment_cycle_link
      then_i_see_information_about_editing_cycle_timetables
      and_i_see_other_content
    end
  end

  context 'Environment is production' do
    scenario 'viewing cycle information when in production', time: mid_cycle do
      given_i_am_signed_in_as_a_support_user
      and_env_is_production
      when_i_click_on_the_recruitment_cycle_link
      then_i_do_not_see_information_about_editing_cycle_timetables
      and_i_see_other_content
    end
  end

private

  def and_env_is_production
    allow(HostingEnvironment).to receive(:production?).and_return true
  end

  def when_i_click_on_the_recruitment_cycle_link
    click_on 'Settings'
    click_on 'Recruitment cycles'
  end

  def then_i_see_information_about_editing_cycle_timetables
    expect(page).to have_title 'Recruitment cycles'
    expect(page).to have_content 'You can edit the following timetables'
    expect(page).to have_link current_year
    expect(page).to have_link next_year
    expect(page).to have_button 'Sync cycle timetables with production'
  end

  def then_i_do_not_see_information_about_editing_cycle_timetables
    expect(page).to have_title 'Recruitment cycles'
    expect(page).to have_no_content 'You can edit the following timetables'
    expect(page).to have_no_link current_year
    expect(page).to have_no_link next_year
    expect(page).to have_no_button 'Sync cycle timetables with production'
  end

  def and_i_see_other_content
    year = current_year
    expect(page).to have_content "Apply has opened (#{year})"
    expect(page).to have_content 'Deadlines'
    expect(page).to have_content 'Cycle years'
  end
end

require 'rails_helper'

RSpec.describe 'Candidate viewing booked interviews' do
  include CandidateHelper
  include ActiveSupport::Testing::TimeHelpers

  scenario 'Candidate is signed out after 7 days if they are not active' do
    given_i_am_signed_in_with_one_login
    and_seven_days_pass
    when_i_click_on_your_details
    then_i_see_the_login_page
  end

  scenario 'The Candidate is signed out 7 days after they are last active' do
    given_i_am_signed_in_with_one_login
    and_three_days_pass
    when_i_click_on_your_details
    then_i_see_my_details

    given_five_more_days_pass
    when_i_click_on_your_details
    then_i_see_my_details

    and_seven_days_pass
    when_i_click_on_your_details
    then_i_see_the_login_page
  end

  def and_seven_days_pass
    travel_by_days(7)
  end

  def given_five_more_days_pass
    travel_by_days(5)
  end

  def and_three_days_pass
    travel_by_days(3)
  end

  def when_i_click_on_your_details
    click_on 'Your details'
  end

  def then_i_see_my_details
    expect(page).to have_content 'Your details'
  end

  def then_i_see_the_login_page
    expect(page).to have_content 'Create an account or sign in'
  end

private

  def travel_by_days(number_of_days)
    advance_time_to number_of_days.days.from_now
  end
end

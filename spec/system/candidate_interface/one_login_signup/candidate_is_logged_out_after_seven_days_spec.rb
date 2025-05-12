require 'rails_helper'

RSpec.describe 'Candidate signs in' do
  include OneLoginHelper

  before do
    FeatureFlag.activate(:one_login_candidate_sign_in)
  end

  scenario 'Candidate uses account before session expiry' do
    given_i_am_logged_in_with_one_login
    and_some_days_pass(6)
    and_i_visit_my_applications_page
    then_i_see_my_applications

    given_some_days_pass(2)
    and_i_visit_my_details_page
    then_i_see_my_details

    given_some_days_pass(7)
    and_i_visit_my_applications_page
    then_i_am_logged_out
  end

  scenario 'Candidate can login again after session expiry' do
    given_i_am_logged_in_with_one_login
    and_some_days_pass(7)
    and_i_visit_my_applications_page
    then_i_am_logged_out

    when_i_login_again
    and_i_visit_my_applications_page
    then_i_see_my_applications
  end

private

  def given_i_am_logged_in_with_one_login
    @candidate = create(:candidate)
    sign_in_with_one_login(@candidate.email_address)
    visit candidate_interface_details_path
  end

  def given_some_days_pass(number_of_days)
    advance_time_to number_of_days.days.from_now
  end
  alias_method :and_some_days_pass, :given_some_days_pass

  def and_i_visit_my_details_page
    click_on 'Your details'
  end

  def and_i_visit_my_applications_page
    click_on 'Your applications'
  end

  def then_i_see_my_details
    expect(page).to have_content 'Your details'
    expect(page).to have_current_path candidate_interface_details_path
  end

  def then_i_see_my_applications
    expect(page).to have_title('Your applications')
    expect(page).to have_current_path candidate_interface_application_choices_path
  end

  def then_i_am_logged_out
    expect(page).to have_title 'Create a GOV.UK One Login or sign in'
    expect(page).to have_content 'You need a GOV.UK One Login to sign in to this service. You can create one if you do not already have one.'
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(path: '/candidate/application/choices')
  end

  def when_i_login_again
    click_on 'Continue'
  end
end

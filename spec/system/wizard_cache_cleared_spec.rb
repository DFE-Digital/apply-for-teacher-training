require 'rails_helper'

RSpec.describe 'Clearing the wizard cache' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  around do |example|
    Timecop.freeze(Time.zone.now) do
      example.run
    end
  end

  scenario 'when the user re-enters a wizard the cache is cleared' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_set_up_interviews_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_click_set_up_an_interview
    and_i_fill_out_the_interview_form(days_in_future: 1, time: '12pm')

    and_i_go_back
    and_i_go_back_again
    then_i_should_be_on_the_application_page

    when_i_click_set_up_an_interview
    then_i_should_see_an_empty_interview_form
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_set_up_interviews_for_my_provider
    provider_user_exists_in_apply_database
    permit_set_up_interviews!
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(application_choice)
  end

  def and_i_click_set_up_an_interview
    click_on 'Set up interview'
  end

  alias_method :when_i_click_set_up_an_interview, :and_i_click_set_up_an_interview

  def and_i_fill_out_the_interview_form(days_in_future:, time:)
    tomorrow = days_in_future.day.from_now
    fill_in 'Day', with: tomorrow.day
    fill_in 'Month', with: tomorrow.month
    fill_in 'Year', with: tomorrow.year

    fill_in 'Time', with: time

    fill_in 'Address or online meeting details', with: 'N/A'

    click_on 'Continue'
  end

  def and_i_go_back
    click_on 'Back'
  end

  alias_method :and_i_go_back_again, :and_i_go_back

  def then_i_should_be_on_the_application_page
    expect(page).to have_current_path(provider_interface_application_choice_path(application_choice))
  end

  def then_i_should_see_an_empty_interview_form
    expect(page).to have_content('Set up an interview')

    expect(page.find_field('Day').value).to be_nil
    expect(page.find_field('Month').value).to be_nil
    expect(page.find_field('Year').value).to be_nil
    expect(page.find_field('Time').value).to be_nil
    expect(page.find_field('Address or online meeting details').value).to be_empty
  end
end

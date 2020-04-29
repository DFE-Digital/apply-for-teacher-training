require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application' do
  include CandidateHelper

  around do |example|
    date_that_avoids_clocks_changing_by_ten_days = Time.zone.local(2020, 1, 13)
    Timecop.freeze(date_that_avoids_clocks_changing_by_ten_days) do
      example.run
    end
  end

  scenario 'Can apply again' do
    given_the_pilot_is_open
    and_apply_again_feature_flag_is_active
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_click_on_start_now

    then_i_see_a_copy_of_my_application
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_apply_again_feature_flag_is_active
    FeatureFlag.activate('apply_again')
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application
    @application_form = create(:completed_application_form, candidate: @candidate)
    create(:application_choice, status: :rejected, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def and_i_click_on_start_now
    click_on 'Start now'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_content('Your new application is ready for editing')
  end
end

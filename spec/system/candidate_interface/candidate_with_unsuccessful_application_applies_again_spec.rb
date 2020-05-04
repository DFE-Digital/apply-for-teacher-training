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

    when_i_select_a_course
    and_submit_the_application

    then_application_is_submitted
    and_application_choices_are_complete
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
    @application_form = create(
      :completed_application_form,
      :with_completed_references,
      references_count: 2,
      with_gces: true,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    create(:application_choice, status: :rejected, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Do you want to apply again?'
  end

  def and_i_click_on_start_now
    click_on 'Start now'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_content('Your new application is ready for editing')
  end

  def when_i_select_a_course
    given_courses_exist
    and_the_suitability_to_work_with_children_feature_flag_is_on

    click_link 'Course choices'
    candidate_fills_in_course_choices
  end

  def and_submit_the_application
    click_link 'Check and submit your application'
    click_link 'Continue'
    choose 'No' # "Is there anything else you would like to tell us?"

    click_button 'Submit application'
  end

  def then_application_is_submitted
    expect(page).to have_content('Application successfully submitted')
  end

  def and_application_choices_are_complete
    expect(ApplicationForm.last.application_choices.first.reload.status).to eq 'application_complete'
  end
end

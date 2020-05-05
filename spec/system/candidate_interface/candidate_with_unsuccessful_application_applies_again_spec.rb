require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application' do
  include CandidateHelper

  scenario 'Can apply again' do
    given_the_pilot_is_open
    and_apply_again_feature_flag_is_active
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_click_on_start_now
    then_i_see_a_copy_of_my_application

    when_i_click_through_to_select_a_course
    then_i_am_informed_i_can_only_select_one_course
    and_i_can_indeed_only_select_one_course

    when_i_complete_my_application
    then_my_application_is_submitted
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

  def when_i_click_through_to_select_a_course
    click_link 'Course choice', exact: true
  end

  def then_i_am_informed_i_can_only_select_one_course
    expect(page).to have_content('You can only apply to 1 course at a time at this stage of your application')
  end

  def and_i_can_indeed_only_select_one_course
    given_courses_exist

    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    choose 'Primary (2XT2)'
    click_button 'Continue'

    expect(page).to have_link 'Delete choice'
    expect(page).to have_content 'I have completed this section'
    expect(page).not_to have_button 'Add another course'
  end

  def when_i_complete_my_application
    check t('application_form.courses.complete.completed_checkbox')
    click_button 'Continue'
    candidate_submits_application
  end

  def then_my_application_is_submitted
    expect(page).to have_content 'Application successfully submitted'
    expect(ApplicationForm.last.application_choices.first.reload.status).to eq 'application_complete'
  end
end

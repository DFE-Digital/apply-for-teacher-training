require 'rails_helper'

RSpec.feature 'Unlocking non editable sections temporarily via support', :continuous_applications do
  include DfESignInHelpers
  include CandidateHelper

  scenario 'Unlocking some sections via support', :with_audited do
    given_i_am_a_support_user
    and_there_is_a_submitted_application

    when_i_visit_the_application_page
    and_i_click_to_change_the_editable_sections
    and_i_click_update
    then_i_see_a_validation_message

    when_i_check_degrees
    and_i_check_english_gcse
    and_i_add_an_audit_comment
    and_click_update
    then_i_see_the_application_page
    and_the_application_is_now_updated_with_the_temporarily_editable_sections

    when_i_signout
    when_candidate_with_submitted_application_logged_in
    then_candidate_can_edit_degrees
    and_candidate_can_edit_english_gcse

    when_the_editable_time_is_expired
    then_candidate_can_not_edit_degrees
    and_candidate_can_not_delete_degrees
    and_candidate_can_not_edit_english_gcse
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application
    @application_form = create(
      :application_form,
      :completed,
      :with_degree_and_gcses,
      application_choices_count: 3,
      submitted_at: 10.days.ago,
    )
    @degree = create(
      :application_qualification,
      application_form: @application_form,
      level: 'degree',
      qualification_type: 'Bachelor of Science',
      subject: 'Rocket',
      grade: 'First-class honours',
      predicted_grade: false,
      award_year: '2020',
      institution_name: 'School of Awesomeness',
    )
    create(:application_choice, :awaiting_provider_decision, application_form: @application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form.id)
  end

  def and_i_click_to_change_the_editable_sections
    within_summary_row 'Editable until' do
      click_link 'Change'
    end
  end

  def and_i_click_update
    click_button 'Update'
  end

  def then_i_see_a_validation_message
    expect(page).to have_content('Add a link to the Zendesk ticket')
  end

  def when_i_check_degrees
    check 'Degree'
  end

  def and_i_check_english_gcse
    check 'English GCSE or equivalent'
  end

  def and_i_add_an_audit_comment
    fill_in 'Zendesk ticket', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_click_update
    click_button 'Update'
  end

  def then_i_see_the_application_page
    expect(page).to have_content('Application form updated')
    expect(page).to have_current_path(support_interface_application_form_path(@application_form.id))
  end

  def and_the_application_is_now_updated_with_the_temporarily_editable_sections
    @application_form.reload
    expect(@application_form.editable_sections).to contain_exactly('english_gcse', 'degrees')
    expect(@application_form.editable_until).to be_within(
      Rails.configuration.x.sections.editable_window_days.business_days.from_now.to_f,
    ).of(Time.zone.now)
  end

  def when_i_signout
    click_link 'Sign out'
  end

  def when_candidate_with_submitted_application_logged_in
    expect(@application_form.submitted_applications?).to be true
    login_as(@application_form.candidate)
    visit root_path
  end

  def then_candidate_can_edit_degrees
    click_link 'Your details'
    click_link 'Degree'
    expect(page).to have_content('Change country for Bachelor of Science, Rocket, School of Awesomeness, 2020')
    click_link 'Change country for Bachelor of Science, Rocket, School of Awesomeness, 2020'
    choose 'Another country'
    select 'Brazil', from: 'Country or territory'
    and_i_click_save_and_continue
    expect(page).to have_current_path(candidate_interface_degree_review_path)
    expect(page).to have_content('Brazil')
  end

  def and_candidate_can_edit_english_gcse
    click_link 'Your details'
    click_link 'English GCSE or equivalent'
    expect(page).to have_content('Change qualification for GCSE, english')
    click_link 'Change qualification for GCSE, english'
    choose 'UK O level (from before 1989)'
    and_i_click_save_and_continue
    fill_in 'Grade', with: 'BB'
    and_i_click_save_and_continue
    fill_in 'Year', with: '1988'
    and_i_click_save_and_continue
    expect(page).to have_current_path(candidate_interface_gcse_review_path('english'))
    expect(page).to have_content('UK O level (from before 1989)')
    expect(page).to have_content('BB')
    expect(page).to have_content('1988')
    expect(page).to have_content('Change qualification for UK O level (from before 1989), english')
  end

  def when_the_editable_time_is_expired
    logout
    advance_time_to(6.business_days.from_now)
    when_candidate_with_submitted_application_logged_in
  end

  def then_candidate_can_not_edit_degrees
    click_link 'Your details'
    click_link 'Degree'
    expect(page).not_to have_content('Change')
    visit candidate_interface_degree_country_path
    and_i_should_be_redirected_to_your_details_page
  end

  def and_candidate_can_not_edit_english_gcse
    click_link 'Your details'
    click_link 'English GCSE or equivalent'
    expect(page).not_to have_content('Change')
    visit candidate_interface_edit_gcse_english_grade_path
    and_i_should_be_redirected_to_your_details_page
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def and_i_should_be_redirected_to_your_details_page
    expect(page).to have_current_path candidate_interface_continuous_applications_details_path
  end

  def and_candidate_can_not_delete_degrees
    expect(page).not_to have_content('Delete')
    visit candidate_interface_confirm_degree_destroy_path(@degree)
    and_i_should_be_redirected_to_your_details_page
  end
end

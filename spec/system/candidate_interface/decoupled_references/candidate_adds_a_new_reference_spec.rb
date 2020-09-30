require 'rails_helper'

RSpec.feature 'Candidate application choices are delivered to providers' do
  include CandidateHelper

  scenario 'the candidate receives an email' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on

    when_i_visit_the_site
    then_i_should_see_the_decoupled_references_section

    when_i_click_add_you_references
    then_i_see_the_start_page

    when_i_click_continue
    then_i_see_the_type_page

    when_i_select_academic
    and_i_click_save_and_continue
    then_i_should_see_the_referee_name_page

    when_i_click_save_and_continue_without_giving_a_name
    then_i_should_see_an_error

    when_i_fill_in_my_references_name
    and_i_click_save_and_continue
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_the_decoupled_references_flag_is_on
    FeatureFlag.activate('decoupled_references')
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_decoupled_references_section
    expect(page).to have_content 'It takes 8 days to get a reference on average.'
  end

  def when_i_click_add_you_references
    click_link 'Add your references'
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_decoupled_references_start_path
  end

  def when_i_click_continue
    click_link 'Continue'
  end

  def then_i_see_the_type_page
    expect(page).to have_current_path candidate_interface_decoupled_references_new_type_path
  end

  def when_i_select_academic
    choose 'Academic'
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def then_i_should_see_the_referee_name_page
    expect(page).to have_current_path candidate_interface_decoupled_references_name_path(@application.application_references.last.id)
  end

  def when_i_click_save_and_continue_without_giving_a_name
    and_i_click_save_and_continue
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'Enter your referees name'
  end

  def when_i_fill_in_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field-error', with: 'Walter White'
  end

  def then_i_see_the_referee_email_page
    expect(page).to have_current_path candidate_interface_decoupled_references_email_path(@application.application_references.last.id)
  end
end

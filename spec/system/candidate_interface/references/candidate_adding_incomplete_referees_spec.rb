require 'rails_helper'

RSpec.describe 'Candidate adding incomplete referees' do
  include CandidateHelper

  it 'Candidate adds incomplete referees and then completes them' do
    given_i_am_signed_in_with_one_login
    and_i_have_provided_my_personal_details

    when_i_provide_a_referee_type_only
    then_i_see_that_referee_is_not_created

    when_i_provide_incomplete_referee_details
    then_i_see_that_the_incomplete_referee_is_created

    when_i_click_to_add_the_email_address
    and_i_provide_a_valid_email_address
    then_i_am_redirected_to_the_review_page

    when_i_click_to_add_the_relationship
    and_i_provide_a_valid_relationship_to_referee
    then_i_am_redirected_to_the_review_page
    and_i_see_that_referee_is_now_complete

    when_the_reference_doesnt_have_a_referee_type
    and_the_references_are_ready_to_be_submitted
    when_i_visit_the_references_review_page
    then_i_see_the_choose_reference_link

    when_i_try_to_complete_the_section
    then_i_see_a_validation_error_message

    when_i_click_on_the_choose_reference_link
    and_i_select_a_referee_type
    then_i_am_redirected_to_the_review_page
    and_i_cant_see_the_choose_reference_link

    when_i_try_to_complete_the_section
    then_i_get_redirected_to_the_application_page
  end

  def when_the_reference_doesnt_have_a_referee_type
    @reference = @current_candidate.current_application.application_references.first
    @current_candidate.current_application.update(references_completed: nil, references_completed_at: nil)
    @reference.update(referee_type: nil)
  end

  def and_the_references_are_ready_to_be_submitted
    create(:reference, :feedback_provided, application_form: @current_candidate.current_application)
  end

  def when_i_visit_the_references_review_page
    visit candidate_interface_references_review_path
  end

  def then_i_see_the_choose_reference_link
    href = candidate_interface_references_edit_type_path(@reference.id, return_to: 'review')
    expect(page).to have_link('Choose a type of referee', href:)
  end

  def when_i_click_on_the_choose_reference_link
    click_link_or_button 'Choose a type of referee'
  end

  def when_i_try_to_complete_the_section
    choose 'Yes, I have completed this section'
    click_link_or_button 'Continue'
  end

  def then_i_see_a_validation_error_message
    expect(page).to have_content 'Enter all required fields for each reference added'
  end

  def and_i_cant_see_the_choose_reference_link
    expect(page).to have_no_link('Choose a type of referee')
  end

  def then_i_get_redirected_to_the_application_page
    expect(page).to have_current_path candidate_interface_details_path
  end

  def and_i_have_provided_my_personal_details
    @current_candidate.current_application.update!(first_name: 'Michael', last_name: 'Antonio')
  end

  def when_i_provide_a_referee_type_only
    visit candidate_interface_references_start_path
    click_link_or_button 'Add reference'
    and_i_select_a_referee_type
  end

  def and_i_select_a_referee_type
    choose 'Academic'
    click_link_or_button t('continue')
  end

  def then_i_see_that_referee_is_not_created
    visit candidate_interface_references_review_path
    expect(page).to have_current_path candidate_interface_references_review_path, ignore_query: true
    expect(page.text).to have_no_content('Academic')
  end

  def when_i_provide_incomplete_referee_details
    visit candidate_interface_references_start_path
    click_link_or_button 'Add reference'
    choose 'Academic'
    click_link_or_button t('continue')
    fill_in t('application_form.references.name.label'), with: 'Mike Dean'
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_that_the_incomplete_referee_is_created
    visit candidate_interface_references_review_path

    within_summary_row('Name') { expect(page.text).to have_content('Mike Dean') }
    within_summary_row('Email') { expect(page).to have_link('Enter email address') }
    within_summary_row('Type') { expect(page.text).to have_content('Academic') }
    within_summary_row('How you know them and for how long') { expect(page).to have_link('Enter how you know them and for how long') }
  end

  def when_i_click_to_add_the_email_address
    click_link_or_button 'Enter email address'
  end

  def and_i_provide_a_valid_email_address
    fill_in t('application_form.references.email_address.label', referee_name: 'Mike Dean'), with: 'mike.dean@example.com'
    click_link_or_button t('save_and_continue')
  end

  def then_i_am_redirected_to_the_review_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def when_i_click_to_add_the_relationship
    click_link_or_button 'Enter how you know them and for how long'
  end

  def and_i_provide_a_valid_relationship_to_referee
    fill_in t('application_form.references.relationship.label', referee_name: 'Mike Dean'), with: 'Gave me a yellow card'
    click_link_or_button t('save_and_continue')
  end

  def and_i_see_that_referee_is_now_complete
    within_summary_row('Name') { expect(page.text).to have_content('Mike Dean') }
    within_summary_row('Email') { expect(page.text).to have_content('mike.dean@example.com') }
    within_summary_row('Type') { expect(page.text).to have_content('Academic') }
    within_summary_row('How you know them and for how long') { expect(page).to have_content('Gave me a yellow card') }
  end
end

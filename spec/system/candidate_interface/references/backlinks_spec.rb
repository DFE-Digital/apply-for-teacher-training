require 'rails_helper'

RSpec.describe 'References' do
  include CandidateHelper

  it 'Candidate adds a new reference' do
    given_i_am_signed_in

    when_i_visit_the_site
    and_i_click_add_your_references
    and_i_click_to_add_a_reference
    and_i_select_academic
    and_i_fill_in_my_references_name
    and_i_click_the_backlink
    then_i_see_the_name_page_with_my_referees_name

    when_i_click_the_backlink
    then_i_see_the_type_page_with_academic_selected

    when_i_choose_school_based
    and_i_change_my_references_name
    and_i_provide_an_email_address
    and_i_click_the_backlink
    then_i_see_the_email_address_page_with_my_referees_email_address

    when_i_click_save_and_continue
    and_provide_my_relationship_to_the_referee
    then_i_see_the_references_review_page
    and_my_referees_details

    when_i_click_change_on_the_references_name
    and_i_click_the_backlink
    then_i_see_the_references_review_page

    when_i_click_change_on_email_address
    and_i_click_the_backlink
    then_i_see_the_references_review_page

    when_i_click_change_on_the_reference_type
    and_i_click_the_backlink
    then_i_see_the_references_review_page

    when_i_click_change_on_relationship
    and_i_click_the_backlink
    then_i_see_the_references_review_page

    when_i_click_change_on_the_references_name
    and_i_click_the_backlink
    then_i_see_the_review_references_page

    when_i_click_change_on_email_address
    and_i_click_the_backlink
    then_i_see_the_review_references_page

    when_i_click_change_on_the_reference_type
    and_i_click_the_backlink
    then_i_see_the_review_references_page

    when_i_click_change_on_relationship
    and_i_click_the_backlink
    then_i_see_the_review_references_page

    when_i_try_and_visit_the_new_type_path_with_a_feedback_provided_reference_id
    then_i_see_the_review_references_page

    when_i_try_and_visit_the_new_name_path_with_a_feedback_provided_reference_id
    then_i_see_the_review_references_page
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = @current_candidate.current_application
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_add_your_references
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def and_i_click_to_add_a_reference
    click_link_or_button 'Add reference'
  end

  def and_i_select_academic
    choose 'Academic'
    and_i_click_continue
  end

  def and_i_fill_in_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field', with: 'Walter White'
    and_i_click_save_and_continue
  end

  def and_i_click_the_backlink
    click_link_or_button 'Back'
  end

  def then_i_see_the_name_page_with_my_referees_name
    expect(page).to have_css("input[value='Walter White']")
  end

  def when_i_click_the_backlink
    and_i_click_the_backlink
  end

  def then_i_see_the_type_page_with_academic_selected
    expect(page).to have_css("input[value='academic']")
  end

  def when_i_choose_school_based
    choose 'School experience'
    and_i_click_continue
  end

  def and_i_change_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field', with: 'Jesse Pinkman'
    and_i_click_save_and_continue
  end

  def and_i_provide_an_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field', with: 'j.pinkman@example.com'
    and_i_click_save_and_continue
  end

  def then_i_see_the_email_address_page_with_my_referees_email_address
    expect(page).to have_css("input[value='j.pinkman@example.com']")
  end

  def and_provide_my_relationship_to_the_referee
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field', with: 'Through nefarious behaviour.'
    and_i_click_save_and_continue
  end

  def then_i_see_the_references_review_page
    expect(page).to have_css('h1', text: 'References to be requested if you accept an offer')
  end

  def and_my_referees_details
    within_summary_row('Name') { expect(page.text).to have_content('Jesse Pinkman') }
    within_summary_row('Email') { expect(page.text).to have_content('j.pinkman@example.com') }
    within_summary_row('Type') { expect(page.text).to have_content('School experience') }
    within_summary_row('How you know them and for how long') { expect(page).to have_content('Through nefarious behaviour') }
  end

  def when_i_click_change_on_the_references_name
    click_link_or_button 'Change name for Jesse Pinkman'
  end

  def when_i_click_change_on_email_address
    click_link_or_button 'Change email address for Jesse Pinkman'
  end

  def when_i_click_change_on_the_reference_type
    click_link_or_button 'Change reference type for Jesse Pinkman'
  end

  def when_i_click_change_on_relationship
    click_link_or_button 'Change relationship for Jesse Pinkman'
  end

  def then_i_see_my_referees_details
    and_my_referees_details
  end

  def and_i_do_not_see_academic_or_the_first_name_i_input
    expect(page).to have_no_content('Academic')
    expect(page).to have_no_content('Walter White')
  end

  def then_i_see_the_review_references_page
    expect(page).to have_current_path candidate_interface_references_review_path
  end

  def when_i_try_and_visit_the_new_type_path_with_a_feedback_provided_reference_id
    @feedback_provided_reference = create(:reference, :feedback_provided, referee_type: 'academic', application_form: @application)
    visit candidate_interface_references_type_path(@feedback_provided_reference.referee_type, @feedback_provided_reference.id)
  end

  def when_i_try_and_visit_the_new_name_path_with_a_feedback_provided_reference_id
    visit candidate_interface_references_name_path(@feedback_provided_reference.referee_type, @feedback_provided_reference.id)
  end

private

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_click_save_and_continue
    and_i_click_save_and_continue
  end
end

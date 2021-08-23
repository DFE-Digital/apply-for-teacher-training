require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  scenario 'Candidate adds a new reference' do
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
    then_i_see_the_unsubmitted_review_page
    and_my_referees_details

    when_i_click_change_on_the_references_name
    and_i_click_the_backlink
    then_i_see_the_unsubmitted_review_page

    when_i_click_change_on_email_address
    and_i_click_the_backlink
    then_i_see_the_unsubmitted_review_page

    when_i_click_change_on_the_reference_type
    and_i_click_the_backlink
    then_i_see_the_unsubmitted_review_page

    when_i_click_change_on_relationship
    and_i_click_the_backlink
    then_i_see_the_unsubmitted_review_page

    when_i_choose_that_im_not_ready_to_submit_my_reference
    then_i_see_my_referees_details
    and_i_should_not_see_academic_or_the_first_name_i_input

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
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_add_your_references
    click_link 'Request your references'
  end

  def and_i_click_to_add_a_reference
    click_link t('continue')
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
    click_link 'Back'
  end

  def then_i_see_the_name_page_with_my_referees_name
    expect(page).to have_selector("input[value='Walter White']")
  end

  def when_i_click_the_backlink
    and_i_click_the_backlink
  end

  def then_i_see_the_type_page_with_academic_selected
    expect(page).to have_selector("input[value='academic']")
  end

  def when_i_choose_school_based
    choose 'School-based'
    and_i_click_continue
  end

  def and_i_change_my_references_name
    fill_in 'candidate-interface-reference-referee-name-form-name-field', with: 'Jesse Pinkman'
    and_i_click_save_and_continue
  end

  def and_i_provide_an_email_address
    fill_in 'candidate-interface-reference-referee-email-address-form-email-address-field', with: 'iamnottheone@whoknocks.com'
    and_i_click_save_and_continue
  end

  def then_i_see_the_email_address_page_with_my_referees_email_address
    expect(page).to have_selector("input[value='iamnottheone@whoknocks.com']")
  end

  def and_provide_my_relationship_to_the_referee
    fill_in 'candidate-interface-reference-referee-relationship-form-relationship-field', with: 'Through nefarious behaviour.'
    and_i_click_save_and_continue
  end

  def then_i_see_the_unsubmitted_review_page
    expect(page).to have_current_path candidate_interface_references_review_unsubmitted_path(@application.application_references.last.id)
  end

  def and_my_referees_details
    within_summary_row('Name') { expect(page.text).to have_content('Jesse Pinkman') }
    within_summary_row('Email address') { expect(page.text).to have_content('iamnottheone@whoknocks.com') }
    within_summary_row('Reference type') { expect(page.text).to have_content('School-based') }
    within_summary_row('Relationship to referee') { expect(page).to have_content('Through nefarious behaviour') }
  end

  def when_i_click_change_on_the_references_name
    page.all('.govuk-summary-list__actions')[0].click_link
  end

  def when_i_click_change_on_email_address
    page.all('.govuk-summary-list__actions')[1].click_link
  end

  def when_i_click_change_on_the_reference_type
    page.all('.govuk-summary-list__actions')[2].click_link
  end

  def when_i_click_change_on_relationship
    page.all('.govuk-summary-list__actions')[3].click_link
  end

  def when_i_choose_that_im_not_ready_to_submit_my_reference
    choose 'No, not at the moment'
    and_i_click_save_and_continue
  end

  def then_i_see_my_referees_details
    and_my_referees_details
  end

  def and_i_should_not_see_academic_or_the_first_name_i_input
    expect(page).not_to have_content 'Academic'
    expect(page).not_to have_content 'Walter White'
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
    click_button t('continue')
  end

  def and_i_click_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_click_save_and_continue
    and_i_click_save_and_continue
  end
end

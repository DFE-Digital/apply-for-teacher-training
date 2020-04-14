require 'rails_helper'

RSpec.describe 'Cancelling a reference' do
  include CandidateHelper

  scenario 'candidate cancels a reference request after completing their application' do
    given_the_training_with_a_disability_flag_is_active
    and_i_have_completed_and_submitted_my_application
    and_the_candidate_cancels_reference_flag_is_active
    and_the_referee_type_flag_is_active
    and_edit_application_is_active

    when_i_visit_the_application_complete_page
    and_i_click_delete_on_my_first_reference
    then_i_should_see_the_confirm_delete_page

    when_i_click_confirm_delete
    then_i_should_see_the_add_referee_type_page
    and_the_referee_should_be_sent_a_cancelation_email

    when_i_choose_academic
    and_click_continue
    then_i_should_see_the_new_referee_page

    when_i_fill_in_the_form
    and_click_continue
    then_i_should_see_the_confirm_referee_page

    when_i_click_confirm_new_referee
    then_my_new_referee_should_receive_a_reference_request_email
    and_i_should_see_the_application_page

    when_i_click_referees
    then_my_previous_reference_should_be_cancelled
    and_my_new_reference_should_have_been_added

    when_i_click_delete_on_another_reference
    and_i_click_confirm_delete
    and_i_visit_the_review_page
    then_i_should_be_able_to_add_a_third_referee
  end

  def given_the_training_with_a_disability_flag_is_active
    FeatureFlag.activate('training_with_a_disability')
  end

  def and_i_have_completed_and_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_the_candidate_cancels_reference_flag_is_active
    FeatureFlag.activate('candidate_cancels_reference')
  end

  def and_the_referee_type_flag_is_active
    FeatureFlag.activate('referee_type')
  end

  def and_edit_application_is_active
    FeatureFlag.activate('edit_application')
  end

  def when_i_visit_the_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def and_i_click_delete_on_my_first_reference
    @reference = ApplicationReference.first
    click_link "Delete referee #{@reference.name}"
  end

  def then_i_should_see_the_confirm_delete_page
    expect(page).to have_current_path(candidate_interface_confirm_destroy_referee_path(@reference.id))
  end

  def when_i_click_confirm_delete
    click_button t('application_form.referees.sure_delete_entry')
  end

  def then_i_should_see_the_add_referee_type_page
    expect(page).to have_current_path(candidate_interface_additional_referee_type_path)
  end

  def and_the_referee_should_be_sent_a_cancelation_email
    open_email(@reference.email_address)

    expect(current_email.subject).to have_content(t('reference_cancelled_email.subject', candidate_name: ApplicationForm.first.full_name))
  end

  def when_i_choose_academic
    choose 'Academic'
  end

  def and_click_continue
    click_button 'Continue'
  end

  def then_i_should_see_the_new_referee_page
    expect(page).to have_current_path(candidate_interface_new_additional_referee_path(type: 'academic'))
  end

  def when_i_fill_in_the_form
    fill_in 'Full name', with: 'AO Reference'
    fill_in 'Email address', with: 'betty@example.com'
    fill_in 'What is your relationship to this referee and how long have you known them?', with: 'Just somebody I used to know'
  end

  def then_i_should_see_the_confirm_referee_page
    expect(page).to have_current_path(candidate_interface_confirm_additional_referees_path)
  end

  def when_i_click_confirm_new_referee
    click_button 'Confirm new referee'
  end

  def then_my_new_referee_should_receive_a_reference_request_email
    open_email('betty@example.com')

    expect(current_email.subject).to have_content(t('reference_request.subject.initial', candidate_name: ApplicationForm.first.full_name))
  end

  def and_i_should_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def when_i_click_referees
    click_link 'Referees'
  end

  def then_my_previous_reference_should_be_cancelled
    expect(first('.app-summary-card__body')).to have_content 'Cancelled'
  end

  def and_my_new_reference_should_have_been_added
    expect(page).to have_content('AO Reference')
  end

  def when_i_click_delete_on_another_reference
    @reference = ApplicationReference.last
    click_link "Delete referee #{@reference.name}"
  end

  def and_i_click_confirm_delete
    when_i_click_confirm_delete
  end

  def and_i_visit_the_review_page
    visit candidate_interface_review_referees_path
  end

  def then_i_should_be_able_to_add_a_third_referee
    expect(page).to have_content('Add referee')
  end
end

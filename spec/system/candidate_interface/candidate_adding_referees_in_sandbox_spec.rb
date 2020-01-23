require 'rails_helper'

RSpec.feature 'Candidate adding referees in Sandbox', sandbox: true do
  include CandidateHelper

  scenario 'Candidate adds two auto-references' do
    given_i_am_signed_in
    and_i_visit_the_application_form

    given_i_have_no_existing_references_on_the_form
    when_i_click_on_referees
    i_see_intro_content_about_choosing_your_referees
    then_when_i_click_continue
    and_i_fill_in_all_required_fields_for_first_reference
    and_i_submit_the_form
    when_i_click_on_back_to_application
    i_see_referees_is_not_complete

    when_i_click_on_referees
    and_i_click_on_add_second_referee
    and_i_fill_in_all_required_fields_for_second_reference
    and_i_submit_the_form
    i_see_both_referees
    save_and_open_page
    then_when_i_click_continue
    i_see_that_the_application_was_sent_to_provider
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_have_no_existing_references_on_the_form
    expect(@current_candidate.application_forms.last.application_references.count).to eq(0)
  end

  def and_i_visit_the_application_form
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_referees
    click_link 'Referees'
  end

  def i_see_intro_content_about_choosing_your_referees
    expect(page).to have_content('Choosing your referees')
  end

  def then_when_i_click_continue
    click_link 'Continue'
  end

  def and_i_click_on_add_referee
    click_link 'Add referee'
  end

  def when_i_click_on_back_to_application
    click_link 'Back to application'
  end

  def and_i_fill_in_name_and_email_address
    fill_in('Full name', with: 'AJP Taylor')
    fill_in('Email address', with: 'ajptaylor@example.com')
  end

  def and_i_submit_the_form
    click_button 'Save and continue'
  end

  def i_see_a_validation_error_on_relationship
    expect(page).to have_content t('activerecord.errors.models.application_reference.attributes.relationship.blank')
  end

  def when_i_enter_a_relationship
    fill_in(t('application_form.referees.relationship.label'), with: 'Thats my tutor, that is')
  end

  def i_see_referees_is_complete
    expect(page).to have_css('#referees-badge-id', text: 'Completed')
  end

  def i_see_referees_is_not_complete
    expect(page).not_to have_css('#referees-badge-id', text: 'Completed')
  end

  def and_i_click_on_add_second_referee
    click_link 'Add a second referee'
  end

  def and_i_fill_in_all_required_fields_for_first_reference
    fill_in('Full name', with: 'Ref Bot 1')
    fill_in('Email address', with: 'refbot1@example.com')
    fill_in(t('application_form.referees.relationship.label'), with: 'Automated referee')
  end

  def and_i_fill_in_all_required_fields_for_second_reference
    fill_in('Full name', with: 'Ref Bot 2')
    fill_in('Email address', with: 'refbot2@example.com')
    fill_in(t('application_form.referees.relationship.label'), with: 'Automated referee')
  end

  def i_see_both_referees
    expect(page).to have_content('Ref Bot 1')
    expect(page).to have_content('refbot1@example.com')

    expect(page).to have_content('Ref Bot 2')
    expect(page).to have_content('refbot2@example.com')
  end

  def i_see_that_the_application_was_sent_to_provider
    require 'pry'; binding.pry
  end
end

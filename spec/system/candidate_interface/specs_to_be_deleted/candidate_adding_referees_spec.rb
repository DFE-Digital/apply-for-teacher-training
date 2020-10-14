require 'rails_helper'

RSpec.feature 'Candidate adding referees' do
  include CandidateHelper

  scenario 'Candidate adds references' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_off
    and_i_visit_the_application_form

    given_i_have_no_existing_references_on_the_form
    when_i_click_on_referees
    then_i_am_asked_to_specify_the_type_of_my_first_reference

    and_i_click_continue
    then_i_see_an_error_to_choose_the_type_of_my_first_reference

    when_i_choose_academic_as_reference_type
    and_i_click_continue
    then_i_am_asked_for_the_details_of_my_academic_referee
    and_i_can_see_the_corresponding_hint_text_for_academic_reference

    when_i_fill_in_name_and_email_address
    and_i_submit_the_form
    then_i_see_a_validation_error_on_relationship

    when_i_enter_a_relationship
    and_i_submit_the_form
    and_i_click_on_back_to_application
    then_i_see_referees_is_not_complete

    when_i_try_to_add_a_referee_with_an_invalid_type
    then_i_see_a_404_page
    and_i_visit_the_application_form
    then_i_see_referees_is_not_complete

    when_i_click_on_referees
    and_i_click_on_add_second_referee
    then_i_am_asked_to_specify_the_type_of_my_second_referee

    when_i_choose_school_based_as_reference_type
    and_i_click_continue
    then_i_am_asked_for_the_details_of_my_school_based_referee
    and_i_can_see_the_corresponding_hint_text_for_school_based_reference

    when_i_fill_in_all_required_fields
    and_i_submit_the_form
    then_i_see_both_referees

    when_i_click_on_change_first_relationship
    then_i_am_asked_for_the_details_of_my_academic_referee
    and_i_can_see_the_corresponding_hint_text_for_academic_reference

    when_i_enter_an_updated_relationship
    and_i_submit_the_form
    then_i_see_updated_reference

    when_i_click_on_change_second_reference_type
    and_i_choose_school_based_as_reference_type
    and_i_click_continue
    then_i_see_the_updated_reference_type

    when_i_mark_the_section_as_completed
    and_i_click_continue
    then_i_see_referees_is_complete

    when_i_navigate_to_the_add_referees_page
    then_i_am_redirected_to_the_referees_review_page
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

  def and_the_decoupled_references_flag_is_off
    FeatureFlag.deactivate('decoupled_references')
  end

  def when_i_click_on_referees
    click_link 'Referees'
  end

  def then_i_see_an_error_to_choose_the_type_of_my_first_reference
    expect(page).to have_content('Choose a type of referee')
  end

  def when_i_choose_academic_as_reference_type
    choose 'Academic'
  end

  def and_i_click_continue
    click_button 'Continue'
  end

  def when_i_click_continue
    click_link 'Continue'
  end

  def then_i_am_asked_to_specify_the_type_of_my_first_reference
    expect(page).to have_content('First referee')
    expect(page).to have_content('What kind of reference are you adding?')
  end

  def and_i_click_on_add_referee
    click_link 'Add referee'
  end

  def and_i_click_on_back_to_application
    click_link 'Back to application'
  end

  def then_i_am_asked_for_the_details_of_my_academic_referee
    expect(page).to have_content('Details of academic referee')
  end

  def and_i_can_see_the_corresponding_hint_text_for_school_based_reference
    expect(page).to have_content('For example, ‘She’s the deputy head at the school where I currently volunteer. I’ve known her for 3 years’.')
  end

  def when_i_fill_in_name_and_email_address
    fill_in('Full name', with: 'AJP Taylor')
    fill_in('Email address', with: 'ajptaylor@example.com')
  end

  def and_i_submit_the_form
    click_button 'Save and continue'
  end

  def then_i_see_a_validation_error_on_relationship
    expect(page).to have_content t('activerecord.errors.models.application_reference.attributes.relationship.blank')
  end

  def when_i_enter_a_relationship
    fill_in(t('application_form.referees.relationship.label'), with: 'Thats my tutor, that is')
  end

  def then_i_see_referees_is_complete
    expect(page).to have_css('#referees-badge-id', text: 'Completed')
  end

  def then_i_see_referees_is_not_complete
    expect(page).not_to have_css('#referees-badge-id', text: 'Completed')
  end

  def and_i_click_on_add_second_referee
    click_link 'Add another referee'
  end

  def then_i_am_asked_to_specify_the_type_of_my_second_referee
    expect(page).to have_content('Second referee')
    expect(page).to have_content('What kind of reference are you adding?')
  end

  def when_i_choose_school_based_as_reference_type
    choose 'School-based'
  end

  def then_i_am_asked_for_the_details_of_my_school_based_referee
    expect(page).to have_content('Details of school-based referee')
  end

  def and_i_can_see_the_corresponding_hint_text_for_academic_reference
    expect(page).to have_content('For example, ‘He was my course supervisor at university. I’ve known him for a year’.')
  end

  def when_i_fill_in_all_required_fields
    full_name_with_trailing_space = 'Bill Lumbergh '
    fill_in('Full name', with: full_name_with_trailing_space)
    fill_in('Email address', with: 'lumbergh@example.com')
    fill_in(t('application_form.referees.relationship.label'), with: 'manager for several years')
  end

  def then_i_see_both_referees
    expect(page).to have_content('AJP Taylor')
    expect(page).to have_content('ajptaylor@example.com')
    expect(page).to have_content('Academic')
    expect(page).to have_content('Thats my tutor, that is')

    full_name_without_trailing_space = "Bill Lumbergh\n"
    expect(page).to have_content(full_name_without_trailing_space)
    expect(page).to have_content('lumbergh@example.com')
    expect(page).to have_content('Academic')
    expect(page).to have_content('manager for several years')
  end

  def when_i_click_on_change_first_relationship
    click_link 'Change relationship for AJP Taylor'
  end

  def when_i_enter_an_updated_relationship
    fill_in(t('application_form.referees.relationship.label'), with: 'Taught me everything I know')
  end

  def then_i_see_updated_reference
    expect(page).to have_content('Taught me everything I know')
  end

  def when_i_click_on_change_second_reference_type
    click_link 'Change reference type for Bill Lumbergh'
  end

  def and_i_choose_school_based_as_reference_type
    choose 'School-based'
  end

  def then_i_see_the_updated_reference_type
    full_name_without_trailing_space = "Bill Lumbergh\n"
    expect(page).to have_content(full_name_without_trailing_space)
    expect(page).to have_content('lumbergh@example.com')
    expect(page).to have_content('School-based')
    expect(page).to have_content('manager for several years')
  end

  def when_i_mark_the_section_as_completed
    check t('application_form.completed_checkbox')
  end

  def when_i_navigate_to_the_add_referees_page
    visit candidate_interface_referees_type_path
  end

  def when_i_try_to_add_a_referee_with_an_invalid_type
    visit candidate_interface_new_referee_path(type: 'not-a-type')
  end

  def then_i_see_a_404_page
    expect(page).to have_content 'Page not found'
  end

  def then_i_am_redirected_to_the_referees_review_page
    expect(page).to have_current_path(candidate_interface_review_referees_path)
  end
end

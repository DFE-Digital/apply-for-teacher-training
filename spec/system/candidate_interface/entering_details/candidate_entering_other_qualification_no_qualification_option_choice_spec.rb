require 'rails_helper'

RSpec.feature 'Entering their other qualifications' do
  include CandidateHelper

  scenario 'Candidate submits their other qualifications after choosing not to provide any' do
    given_i_am_signed_in
    and_i_visit_the_site
    then_i_see_the_other_qualifications_section_is_incomplete

    when_i_click_on_other_qualifications
    then_i_see_the_select_qualification_type_page

    when_i_do_not_select_any_type_option
    and_i_click_continue
    then_i_see_the_qualification_type_error

    when_i_select_i_do_not_want_to_add_any_a_levels
    and_i_click_continue
    then_i_see_a_level_advice
    and_i_see_my_no_other_qualification_selection

    when_i_select_add_another_qualification
    and_i_choose_other
    and_i_click_continue
    and_i_fill_in_my_other_qualifications_details
    and_i_choose_not_to_add_additional_qualifications
    and_click_save_and_continue
    then_i_see_the_other_qualification_review_page
    and_i_dont_see_my_no_other_qualification_selected
    and_see_my_other_uk_qualification_has_the_correct_format

    when_i_click_on_delete_my_first_qualification
    and_i_confirm_that_i_want_to_delete_my_additional_qualification
    then_i_see_the_select_qualification_type_page
    and_i_select_i_do_not_want_to_add_any_a_levels
    and_i_click_continue
    then_i_see_a_level_advice
    and_i_see_my_no_other_qualification_selection

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_see_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_see_the_other_qualifications_section_is_incomplete
    expect(page).to have_css('#a-levels-and-other-qualifications-badge-id', text: 'Incomplete')
  end

  def when_i_click_on_other_qualifications
    click_link t('page_titles.other_qualifications')
  end

  def then_i_see_the_select_qualification_type_page
    expect(page).to have_current_path(candidate_interface_other_qualification_type_path)
  end

  def when_i_select_i_do_not_want_to_add_any_a_levels
    choose 'I do not want to add any A levels and other qualifications'
  end
  alias_method :and_i_select_i_do_not_want_to_add_any_a_levels, :when_i_select_i_do_not_want_to_add_any_a_levels

  def then_i_see_a_level_advice
    expect(page).to have_content('Adding A levels and other qualifications makes your application stronger.')
  end

  def and_i_see_my_no_other_qualification_selection
    expect(page).to have_content('Do you want to add any A levels and other qualifications')
  end

  def and_i_click_continue
    click_button t('continue')
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def and_click_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_choose_other
    choose 'Other'
    within('#candidate-interface-other-qualification-type-form-qualification-type-other-conditional') do
      fill_in 'Qualification name', with: 'Access Course'
    end
  end
  alias_method :and_i_choose_other, :when_i_choose_other

  def when_i_fill_in_my_other_qualifications_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'History, English and Psychology'
    fill_in t('application_form.other_qualification.grade.label'), with: 'Distinction'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2012'
  end
  alias_method :and_i_fill_in_my_other_qualifications_details, :when_i_fill_in_my_other_qualifications_details

  def and_i_choose_not_to_add_additional_qualifications
    choose 'No, not at the moment'
  end

  def then_i_see_the_other_qualification_review_page
    expect(page).to have_current_path(candidate_interface_review_other_qualifications_path)
  end

  def and_i_dont_see_my_no_other_qualification_selected
    expect(page).not_to have_content('Do you want to add any A levels and other qualifications')
  end

  def and_see_my_other_uk_qualification_has_the_correct_format
    @application = current_candidate.current_application
    expect(@application.application_qualifications.last.qualification_type).to eq 'Other'
    expect(@application.application_qualifications.last.other_uk_qualification_type).to eq 'Access Course'
    expect(@application.application_qualifications.last.subject).to eq 'History, English and Psychology'
  end

  def when_i_select_add_another_qualification
    click_link 'Add a qualification'
  end

  def when_i_click_on_delete_my_first_qualification
    within(all('.app-summary-card')[0]) do
      click_link(t('application_form.other_qualification.delete'))
    end
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_qualification
    click_button t('application_form.other_qualification.confirm_delete')
  end

  def when_i_click_on_continue
    click_button t('continue')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.other_qualification.review.completed_checkbox')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_see_that_the_section_is_completed
    expect(page).to have_css('#a-levels-and-other-qualifications-badge-id', text: 'Completed')
  end

  def when_i_do_not_select_any_type_option; end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end
end

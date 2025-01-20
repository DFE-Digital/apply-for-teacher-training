require 'rails_helper'

RSpec.describe 'Change GCSE' do
  include CandidateHelper

  scenario 'Candidate changes their GCSE qualification type' do
    given_i_am_signed_in_with_one_login
    when_i_have_a_completed_english_gcse
    and_i_visit_the_english_review_page
    then_i_click_to_change_the_english_qualification_type

    when_i_choose_other_uk_qualification
    and_click_save_and_continue
    then_i_see_a_validation_error_for_my_qualification_type

    when_i_fill_in_the_other_uk_qualification
    and_click_save_and_continue
    and_i_fill_in_the_qualification_grade
    and_click_save_and_continue
    and_i_fill_in_the_qualification_year
    and_click_save_and_continue
    then_i_see_the_review_page_with_correct_details
  end

  def when_i_have_a_completed_english_gcse
    application_form = current_candidate.current_application
    application_form.application_qualifications << create(:gcse_qualification, subject: 'english')
    application_form.update!(english_gcse_completed: true)
  end

  def and_i_visit_the_english_review_page
    visit candidate_interface_gcse_review_path(subject: 'english')
  end

  def then_i_click_to_change_the_english_qualification_type
    within all('.app-summary-card__body')[0] do
      click_change_link('qualification for GCSE, english')
    end
  end

  def when_i_choose_other_uk_qualification
    choose 'Another UK qualification'
  end

  def and_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_a_validation_error_for_my_qualification_type
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/gcse_qualification_type_form.attributes.other_uk_qualification_type.blank')
  end

  def when_i_fill_in_the_other_uk_qualification
    fill_in 'Qualification name', with: 'Diploma', match: :first
  end

  def and_i_fill_in_the_qualification_grade
    fill_in 'Grade', with: '94%'
  end

  def and_i_fill_in_the_qualification_year
    fill_in 'Year', with: '2013'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'English GCSE or equivalent'
    expect(page).to have_content 'GCSE'
    expect(page).to have_content '94%'
    expect(page).to have_content '2013'
  end
end

require 'rails_helper'

RSpec.feature 'Entering their contact details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details' do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_GCSE_link

    then_i_see_the_add_GCSE_maths_page

    when_i_select_GCSE_option
    then_i_see_the_summary_for_maths_GCSE
  end

  scenario 'Candidate submits their english GCSE details' do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_english_GCSE_link

    then_i_see_the_add_GCSE_english_page

    when_i_select_GCSE_option
    then_i_see_the_summary_for_english_GCSE
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def and_i_click_on_the_english_gcse_link
    click_on 'English GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
    click_button 'Save and continue'
  end

  def then_i_see_the_summary_for_maths_gcse
    expect(page).to have_content 'Maths GCSE or equivalent'
  end

  def then_i_see_the_summary_for_english_gcse
    expect(page).to have_content 'English GCSE or equivalent'
  end

  def and_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'Add English GCSE grade 4 (C) or above, or equivalent'
  end
end

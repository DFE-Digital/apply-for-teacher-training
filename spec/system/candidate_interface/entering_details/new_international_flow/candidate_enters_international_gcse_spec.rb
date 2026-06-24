require 'rails_helper'

RSpec.describe 'Candidate enters a GCSE equivalent qualification from outside of the UK' do
  include CandidateHelper

  scenario 'Candidate submits their maths Non UK GCSE equivalency details and then updates them',
           feature_flag: '2027_international_qualifications_flow' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_non_uk_qualification
    and_i_click_save_and_continue
    then_i_see_the_add_institution_country_page
  end

private

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_text 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_text 'Select the type of qualification'
  end

  def when_i_select_non_uk_qualification
    choose('Qualification from outside the UK')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_do_not_select_any_gcse_option; end

  def then_i_see_the_add_institution_country_page
    expect(page).to have_current_path candidate_interface_gcse_new_international_flow_new_institution_country_path('maths')
  end
end

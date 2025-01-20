require 'rails_helper'

RSpec.describe 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate specifies GCSE maths with "Other UK qualification" type' do
    given_i_am_signed_in_with_one_login
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_other_uk_qualification_option
    and_i_fill_in_the_type_of_qualification

    and_i_click_save_and_continue

    and_i_visit_the_gcse_review_page

    then_i_see_the_review_page_with_correct_details
  end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def when_i_select_other_uk_qualification_option
    choose('Another UK qualification')
  end

  def and_i_fill_in_the_type_of_qualification
    find_by_id('candidate-interface-gcse-qualification-type-form-other-uk-qualification-type-field')
      .set('Scottish Baccalaureate')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_visit_the_candidate_application_page
    visit root_path
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'Scottish Baccalaureate'
  end

  def and_i_visit_the_gcse_review_page
    visit candidate_interface_gcse_review_path(subject: 'maths')
  end
end

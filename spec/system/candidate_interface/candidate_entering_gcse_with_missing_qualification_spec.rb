require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits ' do
    given_i_am_signed_in

    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    and_i_select_i_do_not_have_yet
    and_i_enter_the_missing_explanation
    and_i_click_save_and_continue

    then_i_see_the_review_page_with_correct_details
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def and_i_select_i_do_not_have_yet
    choose('I don’t have this qualification yet')
  end

  def and_i_enter_the_missing_explanation
    fill_in t('application_form.gcse.missing_explanation.label'),
            with: "I'm expecting to complete my Biology course on next July"
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'How I expect to gain this qualification'
    expect(page).to have_content "I'm expecting to complete my Biology course on next July"
  end
end

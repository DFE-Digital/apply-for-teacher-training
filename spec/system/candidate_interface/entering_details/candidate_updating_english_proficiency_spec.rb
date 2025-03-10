require 'rails_helper'

RSpec.describe 'Candidate updating english proficiency' do
  include CandidateHelper

  scenario 'When application form does not have an english proficiency associations' do
    given_i_am_signed_in_with_one_login
    and_i_do_not_have_an_english_proficiency_attached_to_my_application_form
    when_i_visit_the_english_proficiency_edit_path
    then_i_am_able_to_create_an_english_proficiency_record
  end

  def and_i_do_not_have_an_english_proficiency_attached_to_my_application_form
    create(:completed_application_form, candidate: current_candidate)
    expect(current_candidate.current_application.english_proficiency).to be_nil
  end

  def when_i_visit_the_english_proficiency_edit_path
    visit candidate_interface_english_foreign_language_edit_start_path(current_candidate)
  end

  def then_i_am_able_to_create_an_english_proficiency_record
    choose 'Yes'
    complete_efl_form_with_ielts_details
    expect(current_candidate.current_application.english_proficiency).not_to be_nil
  end

  def complete_efl_form_with_ielts_details
    choose 'Yes'
    click_on 'Continue'
    choose 'International English Language Testing System (IELTS)'
    click_on 'Continue'
    fill_in 'Test report form (TRF) number', with: '02GB0674SOOM599A'
    fill_in 'Overall band score', with: '7.5'
    fill_in 'When did you complete the assessment?', with: '2020'
    click_on 'Save and continue'
    choose 'Yes, I have completed this section'
    click_on 'Save changes and return to your details'
  end
end

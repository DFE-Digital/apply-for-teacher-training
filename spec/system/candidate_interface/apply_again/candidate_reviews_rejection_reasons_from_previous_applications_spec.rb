require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application can review rejection reasons when applying again' do
  include CandidateHelper

  scenario 'Apply again and review rejection reasons' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application_with_rejection_reasons
    when_i_apply_again
    then_personal_statement_needs_review
    and_i_can_review_personal_statement

    when_i_confirm_i_have_reviewed_this_section
    then_personal_statement_no_longer_needs_review
    and_i_can_set_it_back_to_unreviewed
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_application_with_rejection_reasons
    application = create(:completed_application_form, candidate: @candidate)
    create(:application_choice, :with_structured_rejection_reasons, application_form: application)
  end

  def when_i_apply_again
    visit candidate_interface_application_complete_path
    click_on 'Apply again'
  end

  def then_personal_statement_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def and_i_can_review_personal_statement
    click_link 'Why do you want to teach'
    expect(page).to have_content 'Use a spellchecker'
  end

  def when_i_confirm_i_have_reviewed_this_section
    check t('application_form.reviewed_checkbox')
    click_button t('continue')
  end

  def then_personal_statement_no_longer_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Completed')
    end
  end

  def and_i_can_set_it_back_to_unreviewed
    click_link 'Why do you want to teach'
    uncheck t('application_form.reviewed_checkbox')
    click_button t('continue')
    then_personal_statement_needs_review
  end
end

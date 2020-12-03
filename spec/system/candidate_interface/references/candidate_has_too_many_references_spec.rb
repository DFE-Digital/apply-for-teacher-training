require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  # We now take steps to prevent more than two references being provided. This
  # wasn't the case historically, however, and a candidate might end up in the
  # following state if they Apply Again from a previous application that had
  # received more than 2 references.
  scenario 'The candidate sees errors when they have too many references' do
    given_i_am_signed_in
    and_i_have_an_application_with_too_many_references
    then_i_see_errors_on_the_reference_review_page
    and_i_see_a_warning_on_the_application_review_page

    when_i_submit_the_application
    then_i_see_an_error_on_the_application_review_page

    when_i_remove_a_reference
    then_i_no_longer_see_errors_on_the_reference_review_page
    and_i_no_longer_see_a_warning_on_the_application_review_page
    and_app_submission_no_longer_triggers_a_reference_section_error
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_application_with_too_many_references
    @candidate.application_forms << create(:application_form)
    create_list(:reference, 3, feedback_status: :feedback_provided, application_form: @candidate.current_application)
  end

  def then_i_see_errors_on_the_reference_review_page
    visit candidate_interface_references_review_path
    within('.app-review-warning--error') do
      expect(page).to have_content 'More than 2 references have been given'
      expect(page).to have_content 'Delete 1 reference. You can only include 2 with your application'
    end
  end

  def and_i_see_a_warning_on_the_application_review_page
    visit candidate_interface_application_review_path
    within('#references > .app-review-warning') do
      expect(page).to have_content 'More than 2 references have been given'
    end
  end

  def when_i_submit_the_application
    click_link 'Continue'
  end

  def then_i_see_an_error_on_the_application_review_page
    within('.govuk-error-summary') do
      expect(page).to have_content 'More than 2 references have been given'
    end
    within('#references > .app-review-warning--error') do
      expect(page).to have_content 'More than 2 references have been given'
      expect(page).to have_content 'Delete 1 reference. You can only include 2 with your application'
    end
  end

  def when_i_remove_a_reference
    all('a', text: 'Delete reference').first.click
    click_on I18n.t('application_form.references.delete_reference.confirm')
  end

  def then_i_no_longer_see_errors_on_the_reference_review_page
    visit candidate_interface_references_review_path
    expect(page).not_to have_content 'More than 2 references have been given'
  end

  def and_i_no_longer_see_a_warning_on_the_application_review_page
    visit candidate_interface_application_review_path
    expect(page).not_to have_content 'More than 2 references have been given'
  end

  def and_app_submission_no_longer_triggers_a_reference_section_error
    click_link 'Continue'
    within('.govuk-error-summary') do
      expect(page).not_to have_content 'More than 2 references have been given'
    end
  end
end

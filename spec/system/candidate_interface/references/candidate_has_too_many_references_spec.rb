require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  before { FeatureFlag.deactivate(:reference_selection) }

  # We now take steps to prevent more than two references being provided. This
  # wasn't the case historically, however, and a candidate might end up in the
  # following state if they Apply Again from a previous application that had
  # received more than 2 references.
  scenario 'The candidate sees errors when they have too many references' do
    given_i_have_a_complete_application
    and_it_has_too_many_references
    then_i_see_errors_on_the_reference_review_page
    and_i_see_a_warning_on_the_application_review_page

    when_i_submit_the_application
    then_i_see_an_error_on_the_application_review_page

    when_i_remove_a_reference
    then_i_no_longer_see_errors_on_the_reference_review_page
    and_i_no_longer_see_a_warning_on_the_application_review_page
    and_app_submission_no_longer_triggers_a_reference_section_error
  end

  def given_i_have_a_complete_application
    candidate_completes_application_form
  end

  def and_it_has_too_many_references
    create(:reference, feedback_status: :feedback_provided, application_form: @application)
  end

  def then_i_see_errors_on_the_reference_review_page
    visit candidate_interface_references_review_path
    within('.app-inset-text--error') do
      expect(page).to have_content 'More than 2 references have been given'
      expect(page).to have_content 'Delete 1 reference. You can only include 2 with your application'
    end
  end

  def and_i_see_a_warning_on_the_application_review_page
    visit candidate_interface_application_review_path
    within('#references > .app-inset-text--important') do
      expect(page).to have_content 'More than 2 references have been given'
    end
  end

  def when_i_submit_the_application
    click_link t('continue')
  end

  def then_i_see_an_error_on_the_application_review_page
    within('.govuk-error-summary') do
      expect(page).to have_content 'More than 2 references have been given'
    end
    within('#references > .app-inset-text--error') do
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
    click_link t('continue')
    expect(page).not_to have_content 'More than 2 references have been given'
    expect(page).to have_current_path candidate_interface_start_equality_and_diversity_path
  end
end

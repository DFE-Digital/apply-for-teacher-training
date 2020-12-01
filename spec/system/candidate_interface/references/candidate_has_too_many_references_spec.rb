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
    when_i_remove_a_reference
    then_i_no_longer_see_errors_on_the_reference_review_page
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
    expect(page).to have_content 'More than 2 references have been given'
    expect(page).to have_content 'Delete 1 reference. You can only include 2 with your application'
  end

  def when_i_remove_a_reference
    all('a', text: 'Delete reference').first.click
    click_on I18n.t('application_form.references.delete_reference.confirm')
  end

  def then_i_no_longer_see_errors_on_the_reference_review_page
    expect(page).not_to have_content 'More than 2 references have been given'
    expect(page).not_to have_content 'Delete 1 reference. You can only include 2 with your application'
  end
end

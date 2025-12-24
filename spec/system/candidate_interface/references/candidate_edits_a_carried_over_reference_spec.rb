require 'rails_helper'

RSpec.describe 'Candidate edits a carried over reference' do
  include CandidateHelper

  scenario 'Can change or delete a reference that has not been requested or received feedback', time: mid_cycle do
    given_i_am_a_candidate_with_a_carried_over_reference
    and_the_status_is_feedback_not_yet_requested

    when_i_login_navigate_to_the_add_references_page
    then_i_see_there_are_change_links
    and_i_can_delete_the_reference
  end

  scenario 'Cannot change a reference in a state of feedback_provided', time: mid_cycle do
    given_i_am_a_candidate_with_a_carried_over_reference
    and_the_status_is_feedback_provided

    when_i_login_navigate_to_the_add_references_page
    then_i_see_there_are_no_change_links
    and_i_cannot_delete_the_reference
  end

private

  def given_i_am_a_candidate_with_a_carried_over_reference
    @candidate = create(:candidate)
    @application = @candidate.current_application
    @reference = create(:application_reference, application_form: @application, duplicate: true)
  end

  def and_the_status_is_feedback_not_yet_requested
    @reference.update(feedback_status: 'not_requested_yet')
  end

  def and_the_status_is_feedback_provided
    @reference.update(feedback_status: 'feedback_provided')
  end

  def when_i_login_navigate_to_the_add_references_page
    login_as(@candidate)
    visit root_path
    click_on 'Your details'
    click_on 'References'
  end

  def then_i_see_there_are_change_links
    expect(page).to have_content('Change')
  end

  def and_i_can_delete_the_reference
    expect(page).to have_content('Delete')
  end

  def then_i_see_there_are_no_change_links
    expect(page).to have_no_content('Change')
  end

  def and_i_cannot_delete_the_reference
    expect(page).to have_no_content('Delete')
  end
end

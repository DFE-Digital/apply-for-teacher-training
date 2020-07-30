require 'rails_helper'

RSpec.feature 'Purge test applications' do
  include DfESignInHelpers

  scenario 'Support user purges test applications' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_candidates_page
    then_i_see_two_candidates

    when_i_visit_the_tasks_page
    and_i_click_on_the_delete_test_applications_button
    and_i_click_the_i_am_sure_button
    and_i_visit_the_candidates_page
    then_i_see_only_one_candidate
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    create :completed_application_form, candidate: create(:candidate, email_address: 'bob@example.com')
    create :completed_application_form, candidate: create(:candidate, email_address: 'alice@example.net')
  end

  def when_i_visit_the_candidates_page
    visit support_interface_candidates_path
  end
  alias_method :and_i_visit_the_candidates_page, :when_i_visit_the_candidates_page

  def then_i_see_two_candidates
    expect(page).to have_content('bob@example.com')
    expect(page).to have_content('alice@example.net')
  end

  def when_i_visit_the_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_the_delete_test_applications_button
    click_button 'Delete test applications'
  end

  def and_i_click_the_i_am_sure_button
    click_button 'I am sure'
  end

  def then_i_see_only_one_candidate
    expect(page).not_to have_content('bob@example.com')
    expect(page).to have_content('alice@example.net')
  end
end

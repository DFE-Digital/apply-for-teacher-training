require 'rails_helper'

RSpec.describe 'See applications' do
  include DfESignInHelpers

  scenario 'Support agent visits the list of applications' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_support_page
    then_i_see_the_latest_applications

    when_i_search_by_application_choice_id
    then_i_see_only_the_associated_application
    and_i_clear_filters

    when_i_search_for_an_application
    then_i_see_only_that_application

    when_my_search_returns_nothing
    then_i_see_a_message_saying_there_are_no_applications
    and_i_clear_filters

    when_i_follow_the_link_to_applications
    then_i_see_the_application_references
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    @completed_application = create(:completed_application_form, first_name: 'Bill', last_name: 'Nugent')
    @unsubmitted_application = create(:application_form, first_name: 'Calpurnia', last_name: 'Salazar')
    @application_with_reference = create(:completed_application_form, first_name: 'Forrest', last_name: 'Cronenberg', application_choices_count: 1)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_see_the_latest_applications
    expect(page).to have_content @completed_application.full_name
    expect(page).to have_content @application_with_reference.full_name
    expect(page).to have_content @unsubmitted_application.full_name
  end

  def when_i_search_by_application_choice_id
    fill_in :application_choice_id, with: @application_with_reference.application_choices.first.id
    click_link_or_button 'Apply filters'
  end

  def then_i_see_only_the_associated_application
    expect(page).to have_content @application_with_reference.full_name
    expect(page).to have_no_content @unsubmitted_application.full_name
    expect(page).to have_no_content @completed_application.full_name
  end

  def and_i_clear_filters
    click_link_or_button 'Clear filters'
  end

  def when_i_search_for_an_application
    fill_in :q, with: @completed_application.candidate.email_address
    click_link_or_button 'Apply filters'
  end

  def then_i_see_only_that_application
    expect(page).to have_content @completed_application.candidate.email_address
    expect(page).to have_no_content @application_with_reference.candidate.email_address
    expect(page).to have_no_content @unsubmitted_application.candidate.email_address
  end

  def when_my_search_returns_nothing
    fill_in :q, with: 'STRING THAT WILL NEVER MATCH'
    click_link_or_button 'Apply filters'
  end

  def then_i_see_a_message_saying_there_are_no_applications
    expect(page).to have_content 'No applications found'
  end

  def when_i_follow_the_link_to_applications
    click_link_or_button 'Applications'
  end

  def then_i_see_the_application_references
    expect(page).to have_content @completed_application.support_reference
    expect(page).to have_content @application_with_reference.support_reference
    expect(page).to have_content @unsubmitted_application.support_reference
  end
end

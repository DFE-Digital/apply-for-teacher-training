require 'rails_helper'

RSpec.describe 'Editing references email address' do
  include CandidateHelper

  scenario 'Changing from personal to professional email address', time: mid_cycle do
    given_i_am_a_candidate_with_a_reference
    and_the_reference_has_a_personal_email_address
    when_i_login_navigate_to_change_reference_email
    and_i_change_to_a_professional_email_address
    then_my_changes_are_saved_with_the_professional_email_address
  end

  scenario 'Changing from professional to personal email address', time: mid_cycle do
    given_i_am_a_candidate_with_a_reference
    and_the_reference_has_a_professional_email_address
    when_i_login_navigate_to_change_reference_email
    and_i_change_to_a_personal_email_address
    then_i_see_the_interruption_page
    and_i_can_save_my_changes_with_the_personal_email_address
  end

private

  def given_i_am_a_candidate_with_a_reference
    @candidate = create(:candidate)
    @application = @candidate.current_application
    @reference = create(:application_reference, application_form: @application)
  end

  def and_the_reference_has_a_professional_email_address
    @reference.update(email_address: 'professional@ucl.ac.uk')
  end

  def and_the_reference_has_a_personal_email_address
    @reference.update(email_address: 'personal@hotmail.com')
  end

  def when_i_login_navigate_to_change_reference_email
    login_as(@candidate)
    visit root_path
    click_on 'Your details'
    click_on 'References'
    click_on "Change email address for #{@reference.name}"
  end

  def and_i_change_to_a_professional_email_address
    fill_in "What is #{@reference.name}’s email address?", with: 'now_professional@open.ac.uk'
    click_on 'Save and continue'
  end

  def and_i_change_to_a_personal_email_address
    fill_in "What is #{@reference.name}’s email address?", with: 'now_personal@yahoo.com'
    click_on 'Save and continue'
  end

  def then_i_do_not_see_the_interruption_page
    expect(page).to have_content "How do you know #{@reference.name} and how long have you known them?"
  end

  def then_i_see_the_interruption_page
    expect(page).to have_content 'now_personal@yahoo.com looks like a personal email address'
    expect(page).to have_content "You should ask #{@reference.name} if they have a work email address you can use instead and update your application."
  end

  def and_i_can_save_my_changes_with_the_personal_email_address
    click_on 'Save and continue'
    expect(page).to have_current_path candidate_interface_references_review_path
    expect(page).to have_content 'now_personal@yahoo.com'
  end

  def then_my_changes_are_saved_with_the_professional_email_address
    expect(page).to have_content 'now_professional@open.ac.uk'
    expect(page).to have_current_path candidate_interface_references_review_path
  end
end

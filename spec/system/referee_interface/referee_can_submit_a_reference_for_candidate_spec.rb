require 'rails_helper'

RSpec.feature 'Referee submits a reference for a candidate', sidekiq: true do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    FeatureFlag.activate('training_with_a_disability')
    FeatureFlag.activate('reference_form')

    given_a_candidate_completed_an_application
    when_the_candidate_submits_the_application
    then_i_receive_an_email_with_a_magic_link

    when_i_try_to_access_the_reference_page_with_invalid_token
    then_i_see_page_not_found

    when_i_click_the_decline_the_link_within_the_email
    then_i_see_the_decline_page

    when_i_click_on_the_link_within_the_email
    then_i_see_the_reference_comment_page

    when_i_fill_in_the_reference_field
    and_i_click_the_submit_button
    then_i_see_the_success_page

    when_i_allow_contact_for_research_purposes
    and_i_click_the_finish_button
    then_i_see_the_thank_you_page_with_research_message

    # When referee declines user research
    when_i_visit_the_confirmation_page
    and_i_dont_allow_contact_for_research_purposes
    and_i_click_the_finish_button
    then_i_see_the_thank_you_page_without_research_message
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
  end

  def then_i_receive_an_email_with_a_magic_link
    open_email('terri@example.com')
    expect(current_email).to have_content(referee_interface_reference_feedback_url(token: referee_token))
  end

  def when_i_try_to_access_the_reference_page_with_invalid_token
    visit referee_interface_reference_feedback_url(token: 'invalid-token')
  end

  def then_i_see_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_click_the_decline_the_link_within_the_email
    current_email.click_link referee_interface_decline_feedback_url(token: referee_token)
  end

  def then_i_see_the_decline_page
    expect(page).to have_content('You’ve declined to give a reference')
    expect(page).to have_content("We will tell #{@application.first_name} #{@application.last_name}")
  end

  def when_i_click_on_the_link_within_the_email
    current_email.click_link referee_interface_reference_feedback_url(token: referee_token)
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Tell us about #{@application.first_name} #{@application.last_name}")
  end

  def when_i_fill_in_the_reference_field
    fill_in 'Your reference', with: 'This is a reference for the candidate.'
  end

  def and_i_click_the_submit_button
    click_button 'Submit reference'
  end

  def then_i_see_the_success_page
    expect(page).to have_content("Your reference for #{@application.first_name} #{@application.last_name}")
  end

  def when_i_allow_contact_for_research_purposes
    choose 'Yes, you can contact me'
  end

  def and_i_click_the_finish_button
    click_button 'Finish'
  end

  def then_i_see_the_thank_you_page_with_research_message
    expect(page).to have_content('Thank you')
    expect(page).to have_content('Our user research team will contact you shortly')
  end

  def when_i_visit_the_confirmation_page
    visit referee_interface_confirmation_path(token: referee_token)
  end

  def and_i_dont_allow_contact_for_research_purposes
    choose 'No, do not contact me'
  end

  def then_i_see_the_thank_you_page_without_research_message
    expect(page).to have_content('Thank you')
    expect(page).not_to have_content('Our user research team will contact you shortly')
  end

private

  def referee_token
    @referee_token ||= Reference.find_by(email_address: 'terri@example.com').token
  end
end

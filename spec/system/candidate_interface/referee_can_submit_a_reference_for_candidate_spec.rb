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

    when_i_click_on_the_link_within_the_email
    then_i_see_the_reference_comment_page
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
  end

  def then_i_receive_an_email_with_a_magic_link
    open_email('terri@example.com')
    expect(current_email).to have_content(referee_interface_reference_comments_url(token: referee_token))
  end

  def when_i_try_to_access_the_reference_page_with_invalid_token
    visit referee_interface_reference_comments_url(token: 'invalid-token')
  end

  def then_i_see_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_click_on_the_link_within_the_email
    current_email.click_link referee_interface_reference_comments_url(token: referee_token)
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Tell us about #{@application.first_name} #{@application.last_name}")
  end

private

  def referee_token
    @referee_token ||= Reference.find_by(email_address: 'terri@example.com').token
  end
end

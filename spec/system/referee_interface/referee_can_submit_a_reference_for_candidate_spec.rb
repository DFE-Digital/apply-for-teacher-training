require 'rails_helper'

RSpec.feature 'Referee can submit reference', sidekiq: true do
  include CandidateHelper

  scenario 'Referee submits a reference for a candidate' do
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

    reference_feedback_url = get_reference_feedback_url(current_email.body)

    expect(reference_feedback_url).not_to be_nil
  end

  def when_i_try_to_access_the_reference_page_with_invalid_token
    visit referee_interface_reference_feedback_path(token: 'invalid-token')
  end

  def then_i_see_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_click_on_the_link_within_the_email
    reference_feedback_url = get_reference_feedback_url(current_email.body)

    current_email.click_link(reference_feedback_url)
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Give a teacher training reference for #{@application.full_name}")
  end

private

  def get_reference_feedback_url(email_content)
    matches = email_content.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    matches.captures.first unless matches.nil?
  end
end

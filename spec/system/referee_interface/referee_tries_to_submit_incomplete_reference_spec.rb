require 'rails_helper'

RSpec.feature 'Stop submission of incomplete references', with_audited: true do
  include CandidateHelper

  scenario 'Referee tries to submit incomplete reference' do
    FeatureFlag.activate(:decoupled_references)

    given_a_candidate_completed_an_application
    then_i_receive_an_email_with_a_magic_link

    when_i_click_on_the_link_within_the_email
    and_i_confirm_my_relationship_with_the_candidate
    and_i_manually_skip_ahead_to_the_review_page
    then_i_cannot_submit_the_reference
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def then_i_receive_an_email_with_a_magic_link
    open_email('terri@example.com')
    matches = current_email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    @token = Rack::Utils.parse_query(URI(matches.captures.first).query)['token']
    @reference_feedback_url = matches.captures.first unless matches.nil?
  end

  def when_i_click_on_the_link_within_the_email
    current_email.click_link(@reference_feedback_url)
  end

  def and_i_confirm_my_relationship_with_the_candidate
    expect(page).to have_content("Confirm how you know #{@application.full_name}")
    choose 'Yes'
    click_button 'Continue'
  end

  def and_i_manually_skip_ahead_to_the_review_page
    visit referee_interface_reference_review_path(token: @token)
  end

  def then_i_cannot_submit_the_reference
    click_button 'Submit reference'
    expect(page).to have_content 'Cannot submit a reference without answers to all questions'
    expect(ApplicationReference.feedback_provided).to be_empty
  end
end

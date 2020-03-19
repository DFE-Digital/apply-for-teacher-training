require 'rails_helper'

RSpec.feature 'Referee can submit reference', with_audited: true do
  include CandidateHelper

  scenario 'Referee submits a reference for a candidate' do
    FeatureFlag.activate('training_with_a_disability')

    given_a_candidate_completed_an_application
    when_the_candidate_submits_the_application
    then_i_receive_an_email_with_a_magic_link
    when_i_try_to_access_the_reference_page_with_invalid_token
    then_i_see_page_not_found

    when_i_click_on_the_link_within_the_email
    then_i_see_the_reference_comment_page

    when_i_fill_in_the_reference_field
    and_i_click_the_submit_reference_button
    then_i_see_am_told_i_submittted_my_refernce
    then_i_see_the_confirmation_page
    and_i_receive_an_email_confirmation
    and_the_candidate_receives_a_notification
    when_i_choose_to_be_contactable
    and_i_click_the_finish_button
    then_i_see_the_thank_you_page
    and_i_am_told_i_will_be_contacted
    when_i_retry_to_edit_the_feedback
    then_i_see_the_thank_you_page
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
  end

  def then_i_receive_an_email_with_a_magic_link
    open_email('terri@example.com')

    matches = current_email.body.match(/(http:\/\/localhost:3000\/reference\?token=[\w-]{20})/)
    @token = Rack::Utils.parse_query(URI(matches.captures.first).query)['token']
    @reference_feedback_url = matches.captures.first unless matches.nil?

    expect(@reference_feedback_url).not_to be_nil
  end

  def when_i_try_to_access_the_reference_page_with_invalid_token
    visit referee_interface_reference_feedback_path(token: 'invalid-token')
  end

  def then_i_see_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_click_on_the_link_within_the_email
    current_email.click_link(@reference_feedback_url)
  end

  def when_i_click_on_continue
    click_button 'Continue'
  end

  def and_i_click_on_continue
    click_button 'Continue'
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Your reference for #{@application.full_name}")
  end

  def when_i_fill_in_the_reference_field
    fill_in 'Your reference', with: 'This is a reference for the candidate.'
  end

  def and_i_click_the_submit_reference_button
    click_button t('reference_form.confirm')
  end

  def and_i_click_the_finish_button
    click_button t('questionnaire_form.confirm')
  end

  def then_i_see_am_told_i_submittted_my_refernce
    expect(page).to have_content("Your reference for #{@application.full_name}")
  end

  def and_i_receive_an_email_confirmation
    open_email('terri@example.com')

    expect(current_email.subject).to have_content(t('reference_confirmation_email.subject', candidate_name: @application.full_name))
  end

  def and_the_candidate_receives_a_notification
    open_email(current_candidate.email_address)

    expect(current_email.subject).to end_with('You have a reference for your teacher training application')
    expect(current_email.body).to have_content('Terri Tudor submitted a reference for your teacher training application')
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content('Thank you')
  end

  def and_i_am_told_i_will_be_contacted
    expect(page).to have_content('Our user research team will contact you shortly')
  end

  def when_i_retry_to_edit_the_feedback
    visit @reference_feedback_url
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(referee_interface_confirmation_path(token: @token))
  end

  def when_i_choose_to_be_contactable
    choose t('questionnaire_form.consent_to_be_contacted')
    fill_in 'Please let us know when you’re available', with: 'anytime 012345 678900'
  end
end

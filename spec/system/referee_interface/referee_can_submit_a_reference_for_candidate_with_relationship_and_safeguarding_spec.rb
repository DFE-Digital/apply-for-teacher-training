require 'rails_helper'

RSpec.feature 'Referee can submit reference', with_audited: true do
  include CandidateHelper

  scenario 'Referee submits a reference for a candidate with relationship, safeguarding and review page' do
    given_i_am_a_referee_of_an_application
    and_i_received_the_initial_reference_request_email
    then_i_receive_an_email_with_a_reference_request

    when_i_try_to_access_the_reference_page_with_invalid_token
    then_i_see_page_not_found

    when_i_click_on_the_link_within_the_email
    and_i_select_yes_to_giving_a_reference
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate

    when_i_click_on_save_and_continue
    then_i_see_an_error_to_confirm_my_relationship_with_the_candidate

    when_i_confirm_that_the_described_relationship_is_not_correct
    and_i_click_on_save_and_continue
    then_i_see_an_error_to_enter_my_relationship_with_the_candidate

    when_i_confirm_that_the_described_relationship_is_correct
    and_i_click_on_save_and_continue
    then_i_see_the_safeguarding_page

    when_i_click_on_save_and_continue
    then_i_see_an_error_to_choose_if_i_know_any_safeguarding_concerns

    when_i_choose_the_candidate_is_not_suitable_for_working_with_children
    and_i_click_on_save_and_continue
    then_i_see_an_error_to_enter_my_safeguarding_concerns

    when_i_choose_the_candidate_is_suitable_for_working_with_children
    and_i_click_on_save_and_continue
    then_i_see_the_reference_comment_page

    # Go backwards
    when_i_click_back
    then_i_see_the_safeguarding_page
    and_i_see_my_previous_safeguarding_answer

    when_i_click_back
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate
    and_i_see_my_previous_relationship_answer

    # Go forwards again
    when_i_click_on_save_and_continue
    when_i_click_on_save_and_continue
    then_i_see_the_reference_comment_page

    when_i_fill_in_the_reference_field
    and_i_click_on_save
    then_i_see_the_reference_review_page

    # Changing answers from the review page
    when_i_click_change_relationship
    and_i_amend_the_relationship
    and_i_click_on_save_and_continue
    then_i_can_review_the_amended_relationship

    when_i_click_change_safeguarding_concerns
    and_i_amend_the_safeguarding_concerns
    and_i_click_on_save_and_continue
    then_i_can_review_the_amended_safeguarding_concerns

    # Check back links from review page
    when_i_click_change_relationship
    when_i_click_back
    then_i_see_the_reference_review_page

    when_i_click_change_safeguarding_concerns
    when_i_click_back
    then_i_see_the_reference_review_page

    when_i_click_change_reference
    when_i_click_back
    then_i_see_the_reference_review_page

    # Submit
    and_i_click_the_submit_reference_button
    then_i_see_am_told_i_submitted_my_reference
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

  def given_i_am_a_referee_of_an_application
    @reference = create(:reference, :feedback_requested, email_address: 'terri@example.com', name: 'Terri Tudor')
    @application = create(
      :completed_application_form,
      references_count: 0,
      application_references: [@reference],
      candidate: current_candidate,
    )
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@reference).deliver_now
  end

  def then_i_receive_an_email_with_a_reference_request
    open_email('terri@example.com')
  end

  def when_i_try_to_access_the_reference_page_with_invalid_token
    visit referee_interface_reference_feedback_path(token: 'invalid-token')
  end

  def then_i_see_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_click_on_the_link_within_the_email
    click_sign_in_link(current_email)
  end

  def and_i_select_yes_to_giving_a_reference
    choose 'Yes, I can give them a reference'
    click_button t('continue')
  end

  def then_i_am_asked_to_confirm_my_relationship_with_the_candidate
    expect(page).to have_content("Confirm how you know #{@application.full_name}")
  end

  def when_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_click_on_save
    click_button t('save')
  end

  def then_i_see_an_error_to_confirm_my_relationship_with_the_candidate
    expect(page).to have_content('Choose if the described relationship is correct')
  end

  def when_i_confirm_that_the_described_relationship_is_not_correct
    within_fieldset('Is this correct?') do
      choose 'No'
    end
  end

  def then_i_see_an_error_to_enter_my_relationship_with_the_candidate
    expect(page).to have_content("Enter your relationship to #{@application.full_name}")
  end

  def when_i_confirm_that_the_described_relationship_is_correct
    within_fieldset('Is this correct?') do
      choose 'Yes'
    end
  end

  def and_i_see_my_previous_relationship_answer
    within_fieldset('Is this correct?') do
      expect(page).to have_checked_field('Yes')
    end
  end

  def then_i_see_the_safeguarding_page
    expect(page).to have_content("Do you know of any reason why #{@application.full_name} should not work with children?")
  end

  def then_i_see_an_error_to_choose_if_i_know_any_safeguarding_concerns
    expect(page).to have_content("Select if you know of any reason why #{@application.full_name} should not work with children")
  end

  def when_i_choose_the_candidate_is_not_suitable_for_working_with_children
    choose 'Yes'
  end

  def then_i_see_an_error_to_enter_my_safeguarding_concerns
    expect(page).to have_content("Enter a reason why #{@application.full_name} should not work with children")
  end

  def when_i_choose_the_candidate_is_suitable_for_working_with_children
    choose 'No'
  end

  def and_i_see_my_previous_safeguarding_answer
    within_fieldset("Do you know of any reason why #{@application.full_name} should not work with children?") do
      expect(page).to have_checked_field('No')
    end
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def and_i_click_on_save
    click_button t('save')
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content("Does #{@application.full_name} have the potential to teach?")
  end

  def when_i_fill_in_the_reference_field
    fill_in 'Your reference', with: 'This is a reference for the candidate.'
  end

  def then_i_see_the_reference_review_page
    expect(page).to have_content("Your reference for #{@application.full_name}")
    expect(page).to have_content('If you’re not ready to submit yet, you can return using the link in your email.')
  end

  def when_i_click_change_relationship
    click_link 'Change relationship'
  end

  def when_i_click_change_reference
    click_link 'Change reference'
  end

  def when_i_click_back
    click_link 'Back'
  end

  def and_i_amend_the_relationship
    choose 'No'
    fill_in "Tell us what your relationship is to #{@application.full_name} and how long you’ve known them", with: 'he is not my friend'
  end

  def then_i_can_review_the_amended_relationship
    click_button t('save_and_continue')
    expect(page).to have_content('he is not my friend')
  end

  def when_i_click_change_safeguarding_concerns
    click_link 'Change concerns about candidate working with children'
  end

  def and_i_amend_the_safeguarding_concerns
    choose 'Yes'
    fill_in "Tell us why you think #{@application.full_name} should not work with children", with: 'telling dirty jokes'
  end

  def then_i_can_review_the_amended_safeguarding_concerns
    expect(page).to have_content('telling dirty jokes')
  end

  def and_i_click_the_submit_reference_button
    click_button t('referee.review.submit')
  end

  def and_i_click_the_finish_button
    click_button t('referee.questionnaire.submit')
  end

  def then_i_see_am_told_i_submitted_my_reference
    expect(page).to have_content("Your reference for #{@application.full_name}")
  end

  def and_i_receive_an_email_confirmation
    open_email('terri@example.com')

    expect(current_email.subject).to have_content(t('reference_confirmation_email.subject', candidate_name: @application.full_name))
  end

  def and_the_candidate_receives_a_notification
    open_email(current_candidate.email_address)

    expect(current_email.subject).to end_with('You have a reference from Terri Tudor')
    expect(current_email.body).to have_content('You need to get another reference')
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content('Thank you')
    expect(page).not_to have_content('You do not need to give a reference anymore.')
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
    choose t('referee.questionnaire.consent_to_be_contacted.yes.label')
    fill_in 'Please let us know when you’re available', with: 'anytime 012345 678900'
  end
end

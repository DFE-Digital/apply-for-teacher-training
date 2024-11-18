require 'rails_helper'

RSpec.describe 'Referee can submit reference in any application choice states', :with_audited, time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  it 'Referee submits a reference' do
    given_i_am_a_referee_of_an_application
    and_i_received_the_initial_reference_request_email
    then_i_receive_an_email_with_a_reference_request
    and_the_candidate_withdraws_from_the_application

    when_i_click_on_the_link_within_the_email
    then_i_see_a_message_about_the_candidate
    and_i_select_yes_to_giving_a_reference
    and_i_select_yes_to_reference_can_be_shared
    then_i_am_asked_to_confirm_my_relationship_with_the_candidate

    when_i_click_on_save_and_continue
    when_i_confirm_that_the_described_relationship_is_correct
    and_i_click_on_save_and_continue
    then_i_see_the_safeguarding_page
    when_i_choose_the_candidate_is_suitable_for_working_with_children
    and_i_click_on_save_and_continue
    then_i_see_the_reference_comment_page
    when_i_fill_in_the_reference_field
    and_i_click_on_save
    then_i_see_the_reference_review_page

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
    @reference = create(:reference, :feedback_requested, referee_type: :academic, email_address: 'terri@example.com', name: 'Terri Tudor')
    @application = create(
      :completed_application_form,
      references_count: 0,
      application_references: [@reference],
      candidate: current_candidate,
    )
    @application_choice = create(:application_choice, :accepted, application_form: @application)
  end

  def and_the_candidate_withdraws_from_the_application
    @application_choice.update!(
      status: 'withdrawn',
      withdrawn_at: Time.zone.now,
      withdrawn_or_declined_for_candidate_by_provider: false,
    )
  end

  def and_i_received_the_initial_reference_request_email
    RefereeMailer.reference_request_email(@reference).deliver_now
  end

  def then_i_receive_an_email_with_a_reference_request
    open_email('terri@example.com')
  end

  def when_i_click_on_the_link_within_the_email
    click_sign_in_link(current_email)
  end

  def then_i_see_a_message_about_the_candidate
    expect(page).to have_content("#{current_candidate.current_application.full_name} has said you can give them a reference for their teacher training application.")
  end

  def and_i_select_yes_to_giving_a_reference
    choose 'Yes, I can give them a reference'
    click_link_or_button t('continue')
  end

  def then_i_am_asked_to_confirm_my_relationship_with_the_candidate
    expect(page).to have_content("Confirm how #{@application.full_name} knows you")
  end

  def and_i_select_yes_to_reference_can_be_shared
    choose 'Yes, if they request it'
    click_link_or_button t('continue')
  end

  def when_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_confirm_that_the_described_relationship_is_correct
    within_fieldset('Is this description accurate?') do
      choose 'Yes'
    end
  end

  def then_i_see_the_safeguarding_page
    expect(page).to have_content("Why #{@application.full_name} should not work with children")
  end

  def when_i_choose_the_candidate_is_suitable_for_working_with_children
    within_fieldset("Do you know any reason why #{@application.full_name} should not work with children?") do
      choose 'No'
    end
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_click_on_save
    click_link_or_button t('save')
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content('when their course started and ended')
    expect(page).to have_content('their academic record')
  end

  def when_i_fill_in_the_reference_field
    fill_in 'Reference', with: 'This is a reference for the candidate.'
  end

  def then_i_see_the_reference_review_page
    expect(page).to have_content("Check your reference for #{@application.full_name}")
  end

  def and_i_click_the_submit_reference_button
    click_link_or_button t('referee.review.submit')
  end

  def and_i_click_the_finish_button
    click_link_or_button t('referee.questionnaire.submit')
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

    expect(current_email.subject).to end_with('Terri Tudor has given you a reference')
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content('Thank you')
    expect(page).to have_no_content('You do not need to give a reference anymore.')
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
    fill_in 'Please let us know when you are available', with: 'anytime 012345 678900'
  end
end

require 'rails_helper'

RSpec.feature 'Referee can submit reference', :with_audited do
  include CandidateHelper

  it 'Referee submits a reference for a candidate with relationship, safeguarding and review page' do
    given_i_am_a_referee_of_an_application_and_i_received_the_email

    when_i_click_on_the_link_within_the_email
    and_i_select_yes_to_giving_a_reference

    when_i_confirm_that_the_described_relationship_is_correct
    then_i_see_the_safeguarding_page

    when_i_choose_the_candidate_is_suitable_for_working_with_children
    then_i_see_the_reference_comment_page

    when_i_fill_in_the_reference_field
    then_i_see_the_reference_review_page

    when_i_click_on_the_link_within_the_email
    and_i_select_yes_to_giving_a_reference

    when_i_confirm_that_the_described_relationship_is_correct
    then_i_see_the_safeguarding_page

    when_i_choose_the_candidate_is_suitable_for_working_with_children
    then_i_see_the_reference_comment_page

    when_i_fill_in_the_reference_field
    then_i_see_the_reference_review_page

    and_i_click_the_submit_reference_button
    then_i_see_am_told_i_submitted_my_reference
    then_i_see_the_confirmation_page
  end

  def given_i_am_a_referee_of_an_application_and_i_received_the_email
    @reference = create(:reference, :feedback_requested, referee_type: :professional, email_address: 'terri@example.com', name: 'Terri Tudor')
    @application = create(
      :completed_application_form,
      references_count: 0,
      application_references: [@reference],
      candidate: current_candidate,
    )
    @application_choice = create(:application_choice, :accepted, application_form: @application)
    RefereeMailer.reference_request_email(@reference).deliver_now
    open_email('terri@example.com')
  end

  def when_i_click_on_the_link_within_the_email
    click_sign_in_link(current_email)
  end

  def and_i_select_yes_to_giving_a_reference
    choose 'Yes, I can give them a reference'
    click_link_or_button t('continue')
  end

  def when_i_confirm_that_the_described_relationship_is_correct
    expect(page).to have_content("Confirm how #{@application.full_name} knows you")
    within_fieldset('Is this description accurate?') do
      choose 'Yes'
    end
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_the_safeguarding_page
    expect(page).to have_content("Do you know any reason why #{@application.full_name} should not work with children?")
  end

  def when_i_choose_the_candidate_is_suitable_for_working_with_children
    choose 'No'
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_the_reference_comment_page
    expect(page).to have_content('when they worked with you')
    expect(page).to have_content('their role and responsibilities')
  end

  def when_i_fill_in_the_reference_field
    fill_in 'Reference', with: 'This is a reference for the candidate.'
    click_link_or_button t('save')
  end

  def then_i_see_the_reference_review_page
    expect(page).to have_content("Check your reference for #{@application.full_name}")
  end

  def and_i_click_the_submit_reference_button
    click_link_or_button t('referee.review.submit')
  end

  def then_i_see_am_told_i_submitted_my_reference
    expect(page).to have_content("Your reference for #{@application.full_name}")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(referee_interface_confirmation_path(token: @token))
  end
end

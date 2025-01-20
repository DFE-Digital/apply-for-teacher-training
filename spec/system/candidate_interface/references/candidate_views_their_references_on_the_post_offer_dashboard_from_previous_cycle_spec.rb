require 'rails_helper'

RSpec.describe 'Post-offer references', :with_audited, time: CycleTimetable.apply_opens(2024) do
  include CandidateHelper

  scenario 'Candidate views their references on the post offer dashboard' do
    given_i_am_signed_in_with_one_login
    and_i_have_an_accepted_offer_from_previous_cycle

    when_i_visit_the_application_dashboard
    then_i_see_the_post_offer_dashboard

    when_i_click_on_my_requested_reference
    then_i_see_my_referee_information
    and_my_available_actions

    when_i_click_send_a_reminder
    then_i_see_the_reminder_confirmation_page

    when_i_confirm_i_want_to_send_the_reminder
    and_i_click_on_my_requested_reference
    then_i_see_the_updated_history

    when_i_go_back_to_the_dashboard
    then_i_see_the_post_offer_dashboard
    then_i_see_the_updated_history_on_the_dashboard
    and_i_click_on_my_requested_reference
    and_i_click_cancel_request
    then_i_see_the_cancellation_confirmation_page

    when_i_confirm_i_want_to_cancel_the_request
    then_i_see_the_status_change
  end

  def and_i_have_an_accepted_offer_from_previous_cycle
    @application_form = create(:completed_application_form, candidate: @current_candidate, recruitment_cycle_year: 2023)
    @pending_reference = create(:reference, :feedback_requested, reminder_sent_at: nil, application_form: @application_form)
    @completed_reference = create(:reference, :feedback_provided, application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :accepted,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def then_i_see_the_post_offer_dashboard
    expect(page).to have_content("Your offer for #{@application_choice.current_course.name_and_code}")
    expect(page).to have_content("You have accepted an offer from #{@application_choice.course_option.course.provider.name} to study #{@application_choice.course.name_and_code}.")
    expect(page).to have_content('References')
    expect(page).to have_content('Offer conditions')
    expect(page).to have_content("#{@application_choice.offer.conditions.first.text} Pending", normalize_ws: true)
  end

  def when_i_click_on_my_requested_reference
    click_link_or_button @pending_reference.name
  end

  alias_method :and_i_click_on_my_requested_reference, :when_i_click_on_my_requested_reference

  def then_i_see_my_referee_information
    expect(page).to have_content(@pending_reference.name)
    expect(page).to have_content(@pending_reference.email_address)
    expect(page).to have_content(@pending_reference.referee_type.humanize)
    expect(page).to have_content(@pending_reference.relationship)
  end

  def and_my_available_actions
    expect(page).to have_content('Send a reminder')
    expect(page).to have_content('Cancel request')
  end

  def when_i_click_send_a_reminder
    click_link_or_button 'Send a reminder'
  end

  def then_i_see_the_reminder_confirmation_page
    expect(page).to have_content("Would you like to send a reminder to #{@pending_reference.name}?")
    expect(page).to have_current_path(candidate_interface_references_new_reminder_path(@pending_reference.id))
    expect(page).to have_content("They’ll also get an automatic reminder on #{@pending_reference.next_automated_chase_at.strftime('%-d %B %Y')}.")
  end

  def when_i_confirm_i_want_to_send_the_reminder
    click_link_or_button 'Send a reminder'
  end

  def then_i_see_the_updated_history
    expect(page).to have_content("You sent a reminder on #{Time.zone.now.to_fs(:govuk_date)}")
  end

  def when_i_go_back_to_the_dashboard
    click_link_or_button 'Back'
  end

  def and_i_click_cancel_request
    click_link_or_button 'Cancel request'
  end

  def then_i_see_the_cancellation_confirmation_page
    expect(page).to have_current_path(candidate_interface_references_confirm_cancel_reference_path(@pending_reference.id))
    expect(page).to have_content("Are you sure you want to cancel the request for a reference from #{@pending_reference.name}?")
    expect(page).to have_content('We will tell them that they no longer need to give a reference.')
  end

  def when_i_confirm_i_want_to_cancel_the_request
    click_link_or_button 'Cancel reference request'
  end

  def then_i_see_the_status_change
    expect(page).to have_content('Request cancelled')
  end

  def then_i_see_the_updated_history_on_the_dashboard
    expect(page).to have_content("Reminder sent on #{Time.zone.now.to_fs(:govuk_date)}")
  end
end

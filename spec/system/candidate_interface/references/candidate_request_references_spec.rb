require 'rails_helper'

RSpec.describe 'New References', :with_audited do
  include CandidateHelper

  scenario 'Candidate request their references on the post offer dashboard' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer

    when_i_visit_the_application_dashboard
    then_i_see_the_post_offer_dashboard

    when_i_click_request_another_reference

    then_the_back_link_point_to_the_offer_dashboard_page
    and_i_am_on_start_page
    and_i_click_continue
    and_i_am_on_the_add_type_page
    and_i_choose_character
    and_i_click_continue
    and_i_am_on_the_add_name_page
    and_the_back_link_point_to_the_add_type_page
    and_i_fill_in_the_reference_name
    and_i_click_save_and_continue
    and_i_am_on_add_email_address_page
    and_the_back_link_point_to_the_add_name_page
    and_i_click_save_and_continue
    then_i_see_the_email_error_validation_message
    when_i_fill_the_email_address
    and_i_click_save_and_continue
    and_i_am_on_add_relationship_page
    and_the_back_link_point_to_the_add_email_address_page
    and_i_fill_in_the_relationship
    and_i_click_save_and_continue
    and_i_am_on_check_your_answers
    and_the_button_request_a_reference_am_on_the_page
    and_the_reference_be_not_sent_yet
    and_i_return_to_the_offer_dashboard
    and_i_click_on_my_reference
    and_i_am_on_check_your_answers
    when_i_click_to_change_the_reference_name
    and_when_i_change_the_reference_name
    and_i_am_on_check_your_answers
    when_i_click_to_change_the_reference_type
    and_when_i_change_the_reference_type
    and_i_am_on_check_your_answers
    when_i_click_to_change_the_reference_email_address
    and_when_i_change_the_reference_email_address
    and_i_am_on_check_your_answers
    when_i_click_to_change_the_reference_relationship
    and_i_change_the_reference_relationship
    and_i_am_on_check_your_answers
    and_i_click_to_request_the_reference
    then_the_reference_be_requested
    and_i_click_cancel_request_from_the_list_page
    then_the_back_link_point_to_the_offer_dashboard_page
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_accepted_offer
    @application_form = create(:completed_application_form, candidate: @candidate)
    @pending_reference = create(:reference, :feedback_requested, reminder_sent_at: nil, application_form: @application_form)
    @completed_reference = create(:reference, :feedback_provided, application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :accepted,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_the_post_offer_dashboard
    expect(page).to have_content("Your offer for #{@application_choice.current_course.name_and_code}")
    expect(page).to have_content("You have accepted an offer from #{@application_choice.course_option.course.provider.name} to study #{@application_choice.course.name_and_code}.")
    expect(page).to have_content('References')
    expect(page).to have_content('Offer conditions')
    expect(page).to have_content("#{@application_choice.offer.conditions.first.text} Pending", normalize_ws: true)
  end

  def when_i_click_request_another_reference
    click_link_or_button 'Request another reference'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def then_the_back_link_point_to_the_offer_dashboard_page
    expect(
      back_link,
    ).to eq(candidate_interface_application_offer_dashboard_path)
  end

  def and_i_am_on_start_page
    expect(page).to have_current_path(candidate_interface_request_reference_references_start_path)
  end

  def and_i_am_on_the_add_type_page
    expect(page).to have_current_path(candidate_interface_request_reference_references_type_path)
  end

  def and_i_am_on_the_add_name_page
    expect(page).to have_current_path(candidate_interface_request_reference_references_name_path('character'))
  end

  def and_the_back_link_point_to_the_add_type_page
    expect(back_link).to eq(candidate_interface_request_reference_references_type_path('character'))
  end

  def and_i_choose_character
    choose 'Character, such as a mentor or someone you know from volunteering'
  end

  def and_i_fill_in_the_reference_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'Aragorn'
  end

  def and_the_back_link_point_to_the_add_name_page
    expect(back_link).to eq(
      candidate_interface_request_reference_references_name_path(
        'character',
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_i_am_on_add_email_address_page
    expect(page).to have_current_path(
      candidate_interface_request_reference_references_email_address_path(
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def when_i_fill_the_email_address
    fill_in 'What is Aragorn’s email address?', with: 'elendil@education.gov.uk'
  end

  def then_i_see_the_email_error_validation_message
    expect(page).to have_content('There is a problem Enter their email address')
  end

  def and_i_am_on_add_relationship_page
    expect(page).to have_current_path(
      candidate_interface_request_reference_references_relationship_path(
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_the_back_link_point_to_the_add_email_address_page
    expect(back_link).to eq(
      candidate_interface_request_reference_references_email_address_path(
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_i_fill_in_the_relationship
    fill_in 'How do you know Aragorn and how long have you known them?', with: 'Lord of the rings'
  end

  def and_i_am_on_check_your_answers
    expect(page).to have_current_path(
      candidate_interface_references_request_reference_review_path(
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_the_button_request_a_reference_am_on_the_page
    expect(page.all('button').map(&:text)).to include('Send reference request')
  end

  def and_the_reference_be_not_sent_yet
    expect(@application_form.reload.application_references.creation_order.last.feedback_status).to eq('not_requested_yet')
  end

  def and_i_return_to_the_offer_dashboard
    visit candidate_interface_application_offer_dashboard_path
  end

  def and_i_click_on_my_reference
    click_link_or_button 'Aragorn'
  end

  def when_i_click_to_change_the_reference_name
    click_link_or_button 'Change name for Aragorn'
  end

  def when_i_click_to_change_the_reference_type
    click_link_or_button 'Change reference type for Aragorn the Middle earth king'
  end

  def when_i_click_to_change_the_reference_email_address
    click_link_or_button 'Change email address for Aragorn the Middle earth king'
  end

  def when_i_click_to_change_the_reference_relationship
    click_link_or_button 'Change relationship for Aragorn the Middle earth king'
  end

  def and_when_i_change_the_reference_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'Aragorn the Middle earth king'
    and_i_click_save_and_continue
  end

  def and_when_i_change_the_reference_type
    choose 'Professional, such as a manager'
    and_i_click_continue
  end

  def and_when_i_change_the_reference_email_address
    fill_in 'What is Aragorn the Middle earth king’s email address?', with: 'aragorn.elendil@education.gov.uk'
    and_i_click_save_and_continue
  end

  def and_i_change_the_reference_relationship
    fill_in 'How do you know Aragorn the Middle earth king and how long have you known them?', with: 'Lord of the rings the two towers'
    and_i_click_save_and_continue
  end

  def and_i_click_to_request_the_reference
    click_link_or_button 'Send reference request'
  end

  def then_the_reference_be_requested
    expect(@application_form.reload.application_references.creation_order.last.feedback_status).to eq('feedback_requested')
    expect(reference_row.text).to include('Requested')
  end

  def reference_row(name = 'Aragorn the Middle earth king')
    page.all('.app-task-list__item').find do |list|
      list.find('a', text: name)
    rescue StandardError
      nil
    end
  end

  def and_i_click_cancel_request_from_the_list_page
    click_link_or_button 'cancel request'
  end

  def back_link
    find('a', text: 'Back')[:href]
  end
end

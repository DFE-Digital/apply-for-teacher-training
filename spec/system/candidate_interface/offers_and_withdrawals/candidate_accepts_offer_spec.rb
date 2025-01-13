require 'rails_helper'

RSpec.describe 'Candidate accepts an offer' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'Candidate views an offer and accepts' do
    given_i_am_signed_in
    and_i_have_2_offers_on_my_choices
    and_1_choice_that_is_awaiting_provider_decision

    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_the_offer
    and_i_am_told_my_other_offer_will_be_automatically_declined

    when_i_continue_without_selecting_a_response
    then_i_see_and_error_message

    when_i_accept_one_offer

    then_i_see_my_references

    and_i_delete_one_of_my_references
    and_i_confirm_the_acceptance

    then_i_see_an_error_message

    when_i_add_another_reference
    then_i_be_on_accept_offer_page

    when_i_click_to_change_the_reference_name
    then_the_back_link_point_to_the_accept_offer_page

    when_i_change_the_reference_name
    then_i_be_on_accept_offer_page
    and_i_see_the_new_reference_name

    when_i_click_to_change_the_reference_type
    then_the_back_link_point_to_the_accept_offer_page

    when_i_change_the_reference_type
    then_i_be_on_accept_offer_page
    and_i_see_the_new_reference_type

    when_i_click_to_change_the_reference_email_address
    then_the_back_link_point_to_the_accept_offer_page

    when_i_change_the_reference_email_address
    then_i_be_on_accept_offer_page
    and_i_see_the_new_reference_email_address

    when_i_click_to_change_the_reference_relationship
    then_the_back_link_point_to_the_accept_offer_page

    when_i_change_the_reference_relationship
    then_i_be_on_accept_offer_page
    and_i_see_the_new_reference_relationship

    when_i_click_to_add_another_reference
    and_i_add_a_reference_type
    and_i_add_a_reference_name
    and_i_add_a_reference_email_address

    and_i_click_back
    and_i_be_on_add_email_address_page

    and_i_click_back
    and_i_be_on_the_existing_add_name_page

    and_i_click_back
    and_i_be_on_the_existing_add_type_page

    and_i_click_back
    then_i_be_on_accept_offer_page

    and_i_confirm_the_acceptance
    then_i_see_an_error_message_about_incomplete_reference

    when_i_add_reference_relationship
    then_i_be_on_accept_offer_page
    and_i_see_your_application_menu_item_as_active

    and_i_confirm_the_acceptance
    then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
    and_i_see_your_offer_menu_item_as_active
    and_i_see_that_i_accepted_the_offer
    and_i_see_that_i_declined_the_other_offer
    and_i_see_that_i_withdrawn_from_the_third_choice
    and_the_provider_has_received_an_email
    and_the_candidate_has_received_an_email

    when_i_visit_the_offer_page_of_the_declined_offer
    then_i_see_the_page_not_found

    when_i_visit_the_accept_page_of_the_declined_offer
    then_i_see_the_page_not_found

    when_i_visit_the_decline_page_of_the_accepted_offer
    then_i_see_the_page_not_found
    when_the_provider_marks_my_application_as_recruited
    and_i_view_my_application
    then_i_see_the_new_dashboard_content

    when_i_click_to_view_my_application
    then_i_see_the_course_with_an_accepted_offer
    and_i_dont_see_the_course_without_an_offer

    when_i_click_back
    then_i_see_the_new_dashboard_content

    when_i_click_to_withdraw_my_application
    and_i_click_back
    then_i_see_the_new_dashboard_content

    when_i_try_to_visit_the_course_selection
    then_i_be_redirected_to_the_offer_dashboard
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_2_offers_on_my_choices
    @application_form = create(
      :completed_application_form,
      first_name: 'Harry',
      last_name: 'Potter',
      candidate: @candidate,
      submitted_at: Time.zone.now,
      support_reference: '123A',
      recruitment_cycle_year: 2024,
    )

    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    other_course_option = course_option_for_provider_code(provider_code: 'DEF')

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@course_option.course.provider])

    @application_choice = create(
      :application_choice,
      :offered,
      course_option: @course_option,
      application_form: @application_form,
    )

    @other_application_choice = create(
      :application_choice,
      :offered,
      course_option: other_course_option,
      application_form: @application_form,
    )
  end

  def and_1_choice_that_is_awaiting_provider_decision
    @third_application_choice = create(
      :application_choice,
      status: 'awaiting_provider_decision',
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def then_i_see_the_offer
    provider = @course_option.course.provider.name
    expect(page).to have_content(provider)
    expect(page).to have_content(t('page_titles.decisions.offer'))
  end

  def and_i_am_told_my_other_offer_will_be_automatically_declined
    expect(page).to have_content('If you accept this offer, your other offer will be automatically declined.')
  end

  def when_i_continue_without_selecting_a_response
    click_link_or_button t('continue')
  end

  def then_i_see_and_error_message
    expect(page).to have_content('Select if you want to accept or decline the offer')
  end

  def when_i_accept_one_offer
    choose 'Accept offer and conditions'
    click_link_or_button t('continue')
  end

  def then_i_see_my_references
    @application_form.reload.application_references.creation_order.each do |reference|
      expect(page).to have_content(reference.name)
      expect(page).to have_content(reference.email_address)
      expect(page).to have_content(reference.relationship)
    end
  end

  def and_i_delete_one_of_my_references
    and_i_click_delete_the_first_reference
    then_the_back_link_point_to_the_accept_offer_page
    and_i_confirm_delete
  end

  def and_i_click_delete_the_first_reference
    click_link_or_button "Delete reference from #{@application_form.application_references.creation_order.first.name}"
  end

  def then_the_back_link_point_to_the_accept_offer_page
    expect(
      back_link,
    ).to eq(candidate_interface_accept_offer_path(@application_choice))
  end

  def then_i_be_on_accept_offer_page
    expect(page).to have_current_path(candidate_interface_accept_offer_path(@application_choice))
  end

  def and_i_confirm_delete
    click_link_or_button 'Yes I’m sure - delete this reference'
  end

  def then_i_see_an_error_message
    expect(page.text).to include("There is a problem\nYou need to have at least 2 references to accept an offer")
  end

  def when_i_add_another_reference
    when_i_click_to_add_another_reference
    then_the_back_link_point_to_the_accept_offer_page
    and_i_be_on_the_add_type_page
    choose 'School experience, such as from the headteacher of a school you have been working in'
    and_i_click_continue
    and_i_be_on_the_add_name_page
    and_the_back_link_point_to_the_add_type_page
    fill_in 'What’s the name of the person who can give a reference?', with: 'Gimli'
    and_i_click_save_and_continue
    and_i_be_on_add_email_address_page
    and_the_back_link_point_to_the_add_name_page
    fill_in 'What is Gimli’s email address?', with: 'gimli@education.gov.uk'
    and_i_click_save_and_continue
    and_i_be_on_add_relationship_page
    and_the_back_link_point_to_the_add_email_address_page
    fill_in 'How do you know Gimli and how long have you known them?', with: 'Lord of the rings'
    and_i_click_save_and_continue
  end

  def and_the_back_link_point_to_the_add_type_page
    expect(
      back_link,
    ).to eq(
      candidate_interface_accept_offer_references_type_path(
        @application_choice,
        'school-based',
      ),
    )
  end

  def and_the_back_link_point_to_the_add_name_page
    expect(
      back_link,
    ).to eq(
      candidate_interface_accept_offer_references_name_path(
        @application_choice,
        'school-based',
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_the_back_link_point_to_the_add_email_address_page
    expect(
      back_link,
    ).to eq(
      candidate_interface_accept_offer_references_email_address_path(
        @application_choice,
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def when_i_click_to_add_another_reference
    click_link_or_button 'Add another reference'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def and_i_add_a_reference_type
    choose 'Professional, such as a manager'
    and_i_click_continue
  end

  def and_i_add_a_reference_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'Aragorn'
    and_i_click_save_and_continue
  end

  def and_i_add_a_reference_email_address
    fill_in 'What is Aragorn’s email address?', with: 'aragorn@education.gov.uk'
    and_i_click_save_and_continue
  end

  def and_i_be_on_the_add_type_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_type_path(@application_choice),
    )
  end

  def and_i_be_on_the_existing_add_type_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_type_path(
        @application_choice,
        'professional',
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_i_be_on_the_add_name_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_name_path(
        @application_choice,
        'school-based',
      ),
    )
  end

  def and_i_be_on_the_existing_add_name_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_name_path(
        @application_choice,
        'professional',
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_i_be_on_add_email_address_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_email_address_path(
        @application_choice,
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def and_i_be_on_add_relationship_page
    expect(page).to have_current_path(
      candidate_interface_accept_offer_references_relationship_path(
        @application_choice,
        @application_form.reload.application_references.creation_order.last.id,
      ),
    )
  end

  def when_i_click_to_change_the_reference_name
    click_link_or_button 'Change name for Gimli'
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end
  alias_method :when_i_click_back, :and_i_click_back

  def when_i_change_the_reference_name
    fill_in 'What’s the name of the person who can give a reference?', with: 'Legolas'
    and_i_click_save_and_continue
  end

  def and_i_see_the_new_reference_name
    expect(page.text).to have_content('Legolas')
  end

  def when_i_click_to_change_the_reference_type
    click_link_or_button 'Change reference type for Legolas'
  end

  def when_i_change_the_reference_type
    choose 'Character, such as a mentor or someone you know from volunteering'
    and_i_click_continue
  end

  def and_i_see_the_new_reference_type
    expect(page.text).to have_content('Character')
  end

  def when_i_click_to_change_the_reference_email_address
    click_link_or_button 'Change email address for Legolas'
  end

  def when_i_change_the_reference_email_address
    fill_in 'What is Legolas’s email address?', with: 'legolas-middle-earth@education.gov.uk'
    and_i_click_save_and_continue
  end

  def and_i_see_the_new_reference_email_address
    expect(page).to have_content('legolas-middle-earth@education.gov.uk')
  end

  def when_i_click_to_change_the_reference_relationship
    click_link_or_button 'Change relationship for Legolas'
  end

  def when_i_change_the_reference_relationship
    fill_in 'How do you know Legolas and how long have you known them?', with: 'The Hobbit'
    and_i_click_save_and_continue
  end

  def and_i_see_the_new_reference_relationship
    expect(page).to have_content('The Hobbit')
  end

  def and_i_confirm_the_acceptance
    expect(page).to have_content 'Your other applications will be withdrawn and any upcoming interviews will be cancelled.'
    click_link_or_button 'Accept offer'
  end

  def then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
    expect(page).to have_content "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def and_i_see_that_i_accepted_the_offer
    expect(page).to have_content "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.course.provider.name}"
  end

  def and_i_see_that_i_declined_the_other_offer
    expect(@other_application_choice.reload.status).to eq 'declined'
  end

  def and_i_see_that_i_withdrawn_from_the_third_choice
    expect(@third_application_choice.reload.status).to eq 'withdrawn'
  end

  def and_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content "Harry Potter accepted your offer for #{@application_choice.course.name}"
  end

  def and_the_candidate_has_received_an_email
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content "You have accepted #{@course_option.course.provider.name}’s offer to study #{@course_option.course.name_and_code}"
  end

  def when_i_visit_the_offer_page_of_the_declined_offer
    visit candidate_interface_offer_path(@other_application_choice.id)
  end

  def when_i_visit_the_accept_page_of_the_declined_offer
    visit candidate_interface_accept_offer_path(@other_application_choice.id)
  end

  def then_i_see_the_page_not_found
    expect(page).to have_content('Page not found')
  end

  def when_i_visit_the_decline_page_of_the_accepted_offer
    visit candidate_interface_decline_offer_path(@application_choice.id)
  end

  def when_i_add_reference_relationship
    click_link_or_button 'Enter how you know them and for how long'
    fill_in 'How do you know Aragorn and how long have you known them?', with: 'Middle earth'
    and_i_click_save_and_continue
  end

  def then_i_see_an_error_message_about_incomplete_reference
    expect(page).to have_content(I18n.t('errors.messages.incomplete_references'))
  end

  def back_link
    find('a', text: 'Back')[:href]
  end

  def when_the_provider_marks_my_application_as_recruited
    @application_choice.recruited!
  end

  def and_i_view_my_application
    visit candidate_interface_application_choices_path
  end

  def then_i_see_the_new_dashboard_content
    expect(page).to have_content "You have accepted an offer from #{@course_option.course.provider.name} to study #{@course_option.course.name_and_code}."
  end

  def and_i_see_your_application_menu_item_as_active
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your application')
  end

  def and_i_see_your_offer_menu_item_as_active
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your offer')
  end

  def when_i_click_to_view_my_application
    click_link_or_button 'View application'
  end

  def when_i_click_to_withdraw_my_application
    click_link_or_button 'Withdraw from the course'
  end

  def then_i_see_the_course_with_an_accepted_offer
    expect(page).to have_content @application_choice.course.name_and_code
  end

  def and_i_dont_see_the_course_without_an_offer
    expect(page).to have_no_content @other_application_choice.course.name_and_code
  end

  def and_the_back_link_point_to_the_offer_dashboard_page
    expect(
      back_link,
    ).to eq(candidate_interface_application_offer_dashboard_path)
  end

  def when_i_try_to_visit_the_course_selection
    visit candidate_interface_course_choices_do_you_know_the_course_path
  end

  def then_i_be_redirected_to_the_offer_dashboard
    expect(page).to have_current_path(candidate_interface_application_offer_dashboard_path)
  end
end

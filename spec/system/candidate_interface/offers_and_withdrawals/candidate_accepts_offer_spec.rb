require 'rails_helper'

RSpec.feature 'Candidate accepts an offer' do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and accepts' do
    given_i_am_signed_in
    and_i_have_2_offers_on_my_choices
    and_1_choice_that_is_awaiting_provider_decision

    when_i_visit_the_application_dashboard
    and_i_click_on_view_and_respond_to_offer_link
    then_i_see_the_offer
    and_i_am_told_my_other_offer_will_be_automatically_declined

    when_i_continue_without_selecting_a_response
    then_i_see_and_error_message

    when_i_accept_one_offer
    and_i_confirm_the_acceptance

    then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
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
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_2_offers_on_my_choices
    @application_form = create(:application_form, first_name: 'Harry', last_name: 'Potter', candidate: @candidate, submitted_at: Time.zone.now,
                                                  support_reference: '123A')

    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    other_course_option = course_option_for_provider_code(provider_code: 'DEF')

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@course_option.course.provider])

    @application_choice = create(
      :application_choice,
      :with_offer,
      course_option: @course_option,
      application_form: @application_form,
    )

    @other_application_choice = create(
      :application_choice,
      :with_offer,
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
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_view_and_respond_to_offer_link
    click_link href: candidate_interface_offer_path(@application_choice)
  end

  def then_i_see_the_offer
    provider = @course_option.course.provider.name
    expect(page).to have_content(provider)
    expect(page).to have_content(t('page_titles.decisions.offer'))
  end

  def and_i_am_told_my_other_offer_will_be_automatically_declined
    expect(page).to have_content('if you accept this offer, your other offer will be automatically declined')
  end

  def when_i_continue_without_selecting_a_response
    click_button t('continue')
  end

  def then_i_see_and_error_message
    expect(page).to have_content('Select if you want to accept or decline the offer')
  end

  def when_i_accept_one_offer
    choose 'Accept offer and conditions'
    click_button t('continue')
  end

  def and_i_confirm_the_acceptance
    click_button 'Accept offer'
  end

  def then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
    expect(page).to have_content "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def and_i_see_that_i_accepted_the_offer
    expect(page).to have_content 'You’ve accepted the offer'

    within "[data-qa=application-choice-#{@application_choice.id}]" do
      expect(page).to have_content 'Offer accepted'
    end
  end

  def and_i_see_that_i_declined_the_other_offer
    within "[data-qa=application-choice-#{@other_application_choice.id}]" do
      expect(page).to have_content 'Offer declined'
    end
  end

  def and_i_see_that_i_withdrawn_from_the_third_choice
    within "[data-qa=application-choice-#{@third_application_choice.id}]" do
      expect(page).to have_content 'Application withdrawn'
    end
  end

  def and_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content 'Harry Potter (123A) has accepted your offer'
  end

  def and_the_candidate_has_received_an_email
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content "You’ve accepted #{@course_option.course.provider.name}’s offer to study #{@course_option.course.name_and_code}"
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
end

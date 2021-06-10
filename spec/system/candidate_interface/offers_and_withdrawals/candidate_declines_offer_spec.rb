require 'rails_helper'

RSpec.feature 'Candidate declines an offer' do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and declines' do
    given_i_am_signed_in
    and_i_have_multiple_offers

    when_i_visit_the_application_dashboard

    when_i_click_on_view_and_respond_to_my_first_offer_link
    and_i_decline_the_offer
    and_i_confirm_the_decline

    then_i_see_a_flash_message_telling_me_i_have_declined_the_offer
    and_i_see_that_i_declined_the_offer
    and_the_provider_receives_a_notification

    when_i_click_on_view_and_respond_to_my_last_offer_link
    and_i_decline_the_offer
    and_i_confirm_the_decline
    then_the_candidate_is_sent_an_email_about_apply_again
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_multiple_offers
    @application_form = create(
      :application_form,
      first_name: 'Harry',
      last_name: 'Potter',
      candidate: @candidate,
      submitted_at: Time.zone.now,
      support_reference: '123A',
    )

    provider = create(:provider, code: 'ABC')

    @course_option = course_option_for_provider(provider: provider)
    course_option2 = course_option_for_provider(provider: provider)

    @application_choice = create(
      :application_choice,
      :with_offer,
      course_option: @course_option,
      application_form: @application_form,
    )

    @application_choice2 = create(
      :application_choice,
      :with_offer,
      course_option: course_option2,
      application_form: @application_form,
    )

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@application_choice.provider])
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def when_i_click_on_view_and_respond_to_my_first_offer_link
    click_link href: candidate_interface_offer_path(@application_choice)
  end

  def and_i_decline_the_offer
    choose 'Decline offer'
    click_button t('continue')
  end

  def and_i_confirm_the_decline
    click_button 'Yes I’m sure – decline this offer'
  end

  def then_i_see_a_flash_message_telling_me_i_have_declined_the_offer
    expect(page).to have_content "You have declined your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def and_i_see_that_i_declined_the_offer
    within "[data-qa=application-choice-#{@application_choice.id}]" do
      expect(page).to have_content 'Offer declined'
    end
  end

  def and_the_provider_receives_a_notification
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content 'Harry Potter (123A) declined an offer'
  end

  def when_i_click_on_view_and_respond_to_my_last_offer_link
    click_link href: candidate_interface_offer_path(@application_choice2)
  end

  def then_the_candidate_is_sent_an_email_about_apply_again
    open_email(@application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You’ve declined an offer: next steps'
  end
end

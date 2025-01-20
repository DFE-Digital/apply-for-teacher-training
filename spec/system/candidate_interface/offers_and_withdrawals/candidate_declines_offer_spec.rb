require 'rails_helper'

RSpec.describe 'Candidate declines an offer' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'Candidate views an offer and declines' do
    given_i_am_signed_in_with_one_login
    and_i_have_multiple_offers

    when_i_visit_my_applications

    and_i_click_to_view_my_application
    and_i_decline_the_offer
    and_i_confirm_the_decline

    then_i_see_a_flash_message_telling_me_i_have_declined_the_offer
    and_i_see_that_i_declined_the_offer
    and_the_provider_receives_a_notification

    when_i_click_on_view_and_respond_to_my_last_offer_link
    and_i_decline_the_offer
    and_i_confirm_the_decline
    then_the_candidate_is_sent_an_email
  end

  def and_i_have_multiple_offers
    @application_form = create(
      :application_form,
      :completed,
      first_name: 'Harry',
      last_name: 'Potter',
      candidate: @current_candidate,
      submitted_at: Time.zone.now,
      support_reference: '123A',
    )

    @course_option = create(:course_option)
    course_option2 = create(:course_option)

    @application_choice = create(
      :application_choice,
      :offered,
      course_option: @course_option,
      application_form: @application_form,
    )

    @application_choice2 = create(
      :application_choice,
      :offered,
      course_option: course_option2,
      application_form: @application_form,
    )

    @provider_user = create(:provider_user, :with_notifications_enabled, providers: [@application_choice.provider])
  end

  def and_i_decline_the_offer
    choose 'Decline offer'
    click_link_or_button t('continue')
  end

  def and_i_confirm_the_decline
    click_link_or_button 'Yes I’m sure – decline this offer'
  end

  def then_i_see_a_flash_message_telling_me_i_have_declined_the_offer
    expect(page).to have_content "You have declined your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def and_i_see_that_i_declined_the_offer
    expect(page).to have_content 'Offer declined'
  end

  def and_the_provider_receives_a_notification
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content 'Harry Potter declined your offer'
  end

  def when_i_click_on_view_and_respond_to_my_last_offer_link
    @application_choice = @application_choice2
    when_i_click_to_view_my_application
  end

  def then_the_candidate_is_sent_an_email
    open_email(@application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You have declined an offer: next steps'
  end
end

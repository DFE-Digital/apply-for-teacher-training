require 'rails_helper'

RSpec.feature 'Candidate declines an offer', sidekiq: true do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and declines' do
    given_i_am_signed_in
    and_i_have_an_offer

    when_i_visit_the_application_dashboard

    when_i_click_on_view_and_respond_to_offer_link
    and_i_decline_the_offer
    and_i_confirm_the_decline

    then_a_slack_notification_is_sent
    and_i_see_that_i_declined_the_offer
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_offer
    application_form = create(:application_form, first_name: 'Harry', candidate: @candidate, submitted_at: DateTime.now)

    @course_option = course_option_for_provider_code(provider_code: 'ABC')

    @application_choice = create(
      :application_choice,
      :with_offer,
      course_option: @course_option,
      application_form: application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def when_i_click_on_view_and_respond_to_offer_link
    click_link href: candidate_interface_offer_path(@application_choice)
  end

  def and_i_decline_the_offer
    choose 'Decline offer'
    click_button 'Continue'
  end

  def and_i_confirm_the_decline
    click_button 'Yes I’m sure - decline this offer'
  end

  def then_a_slack_notification_is_sent
    expect_slack_message_with_text "Harry has declined #{@course_option.course.provider.name}'s offer"
  end

  def and_i_see_that_i_declined_the_offer
    within ".qa-application-choice-#{@application_choice.id}" do
      expect(page).to have_content 'Declined'
    end
  end
end

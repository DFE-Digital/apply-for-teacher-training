require 'rails_helper'

RSpec.feature 'Candidate declines an offer', sidekiq: true do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and declines' do
    given_i_am_signed_in
    and_i_have_an_offer

    when_i_visit_the_application_dashboard
    then_i_see_the_view_and_respond_to_offer_link

    when_i_click_on_view_and_respond_to_offer_link
    and_i_decline_the_offer
    and_i_confirm_the_decline

    then_a_slack_notification_is_sent
    when_i_visit_the_application_dashboard
    and_the_offer_is_declined
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
      status: 'offer',
      offer: { 'conditions' => ['Fitness to teach check', 'Be cool'] },
      course_option: @course_option,
      application_form: application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_the_view_and_respond_to_offer_link
    expect(page).to have_content(t('application_form.courses.view_and_respond_to_offer'))
  end

  def when_i_click_on_view_and_respond_to_offer_link
    click_link href: candidate_interface_offer_path(@application_choice)
  end

  def and_i_decline_the_offer
    choose 'Decline offer'
    click_button 'Continue'
  end

  def and_i_confirm_the_decline
    click_button 'Confirm decline'
  end

  def then_a_slack_notification_is_sent
    expect_slack_message "Harry has declined #{@course_option.course.provider.name}'s offer"
  end

  def and_the_offer_is_declined
    # TODO: check the frontend
    expect(@application_choice.reload.status).to eql('declined')
  end
end

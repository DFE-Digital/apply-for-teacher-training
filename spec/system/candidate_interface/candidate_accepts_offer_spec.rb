require 'rails_helper'

RSpec.feature 'Candidate accepts an offer', sidekiq: true do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and accepts' do
    given_i_am_signed_in
    and_i_have_2_offers_on_my_choices
    and_1_withdrawn_choice

    when_i_visit_the_application_dashboard
    then_i_see_the_view_and_respond_to_offer_link

    when_i_click_on_view_and_respond_to_offer_link
    then_i_see_the_offer

    when_i_accept_one_offer
    and_i_confirm_the_acceptance

    then_a_slack_notification_is_sent

    when_i_visit_the_application_dashboard
    then_that_offer_is_accepted
    and_the_other_offer_is_declined
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_2_offers_on_my_choices
    @application_form = create(:application_form, first_name: 'Harry', candidate: @candidate, submitted_at: DateTime.now)

    @course_option = course_option_for_provider_code(provider_code: 'ABC')
    other_course_option = course_option_for_provider_code(provider_code: 'DEF')

    @application_choice = create(
      :application_choice,
      status: 'offer',
      offer: { 'conditions' => ['Fitness to teach check', 'Be cool'] },
      course_option: @course_option,
      application_form: @application_form,
    )

    @other_application_choice = create(
      :application_choice,
      status: 'offer',
      offer: { 'conditions' => ['Be cool'] },
      course_option: other_course_option,
      application_form: @application_form,
    )
  end

  def and_1_withdrawn_choice
    create(
      :application_choice,
      status: 'withdrawn',
      application_form: @application_form,
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

  def then_i_see_the_offer
    provider = @course_option.course.provider.name
    expect(page).to have_content(provider)
    expect(page).to have_content(t('page_titles.view_and_respond_to_offer'))
    expect(page).to have_content(
      "Do you want to respond to your offer to study #{@course_option.course.name} (#{@course_option.course.code}) at #{provider} now?",
    )
  end

  def when_i_accept_one_offer
    choose 'Accept offer and conditions'
    click_button 'Continue'
  end

  def and_i_confirm_the_acceptance
    click_button 'Confirm accept'
  end

  def then_a_slack_notification_is_sent
    expect_slack_message "Harry has accepted #{@course_option.course.provider.name}'s offer"
  end

  def then_that_offer_is_accepted
    expect(page).to have_content 'You have accepted an offer'
    # TODO: check the frontend
    expect(@application_choice.reload.status).to eql('pending_conditions')
  end

  def and_the_other_offer_is_declined
    # TODO: check the frontend
    expect(@other_application_choice.reload.status).to eql('declined')
  end
end

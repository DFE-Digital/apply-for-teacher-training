require 'rails_helper'

RSpec.feature 'Candidate accepts an offer', sidekiq: true do
  include CourseOptionHelpers

  scenario 'Candidate views an offer and accepts' do
    given_the_accept_and_decline_feature_is_on

    given_i_am_signed_in
    and_i_have_2_offers_on_my_choices
    and_1_withdrawn_choice

    when_i_visit_the_application_dashboard
    and_i_click_on_view_and_respond_to_offer_link
    then_i_see_the_offer

    when_i_accept_one_offer
    and_i_confirm_the_acceptance

    then_a_slack_notification_is_sent
    and_i_see_that_i_accepted_the_offer
    and_i_see_that_i_declined_the_other_offer

    when_i_have_another_application_without_offer
    and_i_visit_the_offer_page
    then_i_see_the_applcation_dashboard
  end

  def given_the_accept_and_decline_feature_is_on
    FeatureFlag.activate('accept_and_decline_via_ui')
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

  def and_i_click_on_view_and_respond_to_offer_link
    click_link href: candidate_interface_offer_path(@application_choice)
  end

  def then_i_see_the_offer
    provider = @course_option.course.provider.name
    expect(page).to have_content(provider)
    expect(page).to have_content(t('page_titles.view_and_respond_to_offer'))
  end

  def when_i_accept_one_offer
    choose 'Accept offer and conditions'
    click_button 'Continue'
  end

  def and_i_confirm_the_acceptance
    click_button 'Accept offer'
  end

  def then_a_slack_notification_is_sent
    expect_slack_message_with_text "Harry has accepted #{@course_option.course.provider.name}'s offer"
  end

  def and_i_see_that_i_accepted_the_offer
    expect(page).to have_content 'You have accepted an offer'

    within ".qa-application-choice-#{@application_choice.id}" do
      expect(page).to have_content 'Accepted'
    end
  end

  def and_i_see_that_i_declined_the_other_offer
    within ".qa-application-choice-#{@other_application_choice.id}" do
      expect(page).to have_content 'Declined'
    end
  end

  def when_i_have_another_application_without_offer
    @application_choice_without_offer = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: @course_option,
      application_form: @application_form,
    )
  end

  def and_i_visit_the_offer_page
    visit candidate_interface_offer_path(id: @application_choice_without_offer.id)
  end

  def then_i_see_the_applcation_dashboard
    expect(page).to have_content('Application dashboard')
  end
end

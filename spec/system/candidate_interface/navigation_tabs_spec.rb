require 'rails_helper'

RSpec.describe 'Primary Navigation' do
  include CandidateHelper
  scenario 'highlights the primary navigation for pre continuous applications' do
    given_i_am_signed_in
    and_i_have_pre_continuous_applications_submitted
    when_i_visit_the_application_dashboard
    then_i_see_your_application_as_active
  end

  scenario 'highlights the primary navigation correct item for continuous applications' do
    given_i_am_signed_in
    and_i_have_submitted_applications
    when_i_visit_the_application_dashboard
    then_i_see_your_details_as_active

    when_i_click_on_personal_information
    then_i_see_your_details_as_active

    when_i_click_on_your_applications
    then_i_see_your_applications_as_active

    when_i_click_on_an_application
    then_i_see_your_applications_as_active

    when_i_click_on_change_course
    then_i_see_your_applications_as_active

    when_i_visit_guidance_page_without_referer
    then_i_see_your_details_as_active
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_pre_continuous_applications_submitted
    application_form = create(
      :application_form,
      :submitted,
      :pre_continuous_applications,
      candidate: current_candidate,
    )
    create(
      :application_choice,
      :rejected,
      application_form:,
    )
  end

  def and_i_have_submitted_applications
    application_form = create(
      :application_form,
      :unsubmitted,
      candidate: current_candidate,
    )
    @application_choice = create(
      :application_choice,
      :unsubmitted,
      application_form:,
    )
  end

  def when_i_visit_the_application_dashboard
    visit(candidate_interface_details_path)
  end

  def when_i_click_on_personal_information
    click_link_or_button 'Personal information'
  end

  def when_i_click_on_your_applications
    click_link_or_button 'Your applications'
  end

  def when_i_click_on_an_application
    click_link_or_button @application_choice.current_course.provider.name
  end

  def when_i_click_on_change_course
    click_link_or_button 'Change'
  end

  def then_i_see_your_details_as_active
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your details')
  end

  def then_i_see_your_application_as_active
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your application')
  end

  def then_i_see_your_applications_as_active
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your applications')
  end

  def when_i_visit_guidance_page_without_referer
    visit(candidate_interface_guidance_path)
  end
end

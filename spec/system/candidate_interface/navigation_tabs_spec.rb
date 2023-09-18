require 'rails_helper'

RSpec.describe 'Primary Navigation', continuous_applications: false do
  include CandidateHelper
  scenario 'highlights the primary navigation' do
    given_i_am_signed_in
    when_i_visit_the_application_dashboard
    then_i_should_see_your_application_as_active
  end

  scenario 'highlights the primary navigation correct item for continuous applications', :continuous_applications, :js do
    given_i_am_signed_in
    when_i_visit_the_application_dashboard
    then_i_should_see_your_details_as_active

    when_i_click_on_personal_information
    then_i_should_see_your_details_as_active

    when_i_click_on_your_applications
    then_i_should_see_your_applications_as_active

    when_i_visit_guidance_page_without_referer
    then_i_should_see_your_details_as_active
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_application_dashboard
    visit(candidate_interface_application_form_path)
  end

  def when_i_click_on_personal_information
    click_link 'Personal information'
  end

  def when_i_click_on_your_applications
    click_link 'Your applications'
  end

  def then_i_should_see_your_details_as_active
    expect(page).to have_css('.govuk-link.app-primary-navigation__link[aria-current=page]', text: 'Your details')
  end

  def then_i_should_see_your_application_as_active
    expect(page).to have_css('.govuk-link.app-primary-navigation__link[aria-current=page]', text: 'Your application')
  end

  def then_i_should_see_your_applications_as_active
    expect(page).to have_css('.govuk-link.app-primary-navigation__link[aria-current=page]', text: 'Your applications')
  end

  def when_i_visit_guidance_page_without_referer
    visit(candidate_interface_guidance_path)
  end
end

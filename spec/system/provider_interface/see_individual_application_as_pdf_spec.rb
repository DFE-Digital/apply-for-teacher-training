require 'rails_helper'

RSpec.describe 'Provider sees an application as PDF' do
  include CourseOptionHelpers
  include DfESignInHelpers

  it 'viewing application in PDF format', skip: 'Fails on CI since chromium update, pending until alternative to grover is found or new version of chrome' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_an_application_exists

    when_i_visit_the_provider_application_page
    and_i_click_the_applications_pdf_link
    then_i_see_the_application_choice_in_pdf_format

    when_i_visit_the_provider_application_references_page
    and_i_click_the_references_pdf_link
    then_i_see_the_application_references_in_pdf_format
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
  end

  def and_an_application_exists
    @course_option = course_option_for_provider(
      provider: @provider_user.providers.first,
      course: build(:course, provider: @provider_user.providers.first),
    )

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: @course_option,
      status: 'offer',
      offered_at: 1.day.ago,
      updated_at: 1.day.ago,
    )
  end

  def when_i_visit_the_provider_application_page
    visit provider_interface_application_choice_path(@application_choice.id)
  end

  def and_i_click_the_applications_pdf_link
    click_link_or_button 'Download application (PDF)'
  end

  def then_i_see_the_application_choice_in_pdf_format
    expect(page.driver.response.status).to eq(200)
    expect(page.driver.response.content_type).to eq('application/pdf')
    expect(page.driver.response.length).to be > 0
  end

  def when_i_visit_the_provider_application_references_page
    visit provider_interface_application_choice_references_path(@application_choice.id)
  end

  def and_i_click_the_references_pdf_link
    click_link_or_button 'Download references (PDF)'
  end

  def then_i_see_the_application_references_in_pdf_format
    expect(page.driver.response.status).to eq(200)
    expect(page.driver.response.content_type).to eq('application/pdf')
    expect(page.driver.response.length).to be > 0
  end
end

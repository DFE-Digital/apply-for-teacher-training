require 'rails_helper'

RSpec.feature 'Candidate signs in and starts blank application' do
  include SignInHelper

  scenario 'User can start an application and then view the guidance' do
    given_a_course_is_available
    and_the_continuous_applications_feature_is_enabled
    and_i_am_a_candidate_with_a_blank_application

    when_i_fill_in_the_sign_in_form
    and_i_click_on_the_link_in_my_email_and_sign_in
    then_i_am_taken_to_the_application_page

    when_i_click_on_the_guidance_link
    then_i_am_taken_to_the_guidance_page
  end

  def given_a_course_is_available
    create(:course_option, course: create(:course, :open_on_apply))
  end

  def and_the_continuous_applications_feature_is_enabled
    FeatureFlag.activate(:continuous_applications)
  end

  def and_i_am_a_candidate_with_a_blank_application
    @candidate = create(:candidate)
    @application_form = create(:application_form, candidate: @candidate)
  end

  def when_i_fill_in_the_sign_in_form
    visit candidate_interface_sign_in_path
    fill_in t('authentication.sign_up.email_address.label'), with: @candidate.email_address
    click_on t('continue')
  end

  def and_i_click_on_the_link_in_my_email_and_sign_in
    open_email(@candidate.email_address)
    click_magic_link_in_email
    confirm_sign_in
  end

  def then_i_am_taken_to_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def when_i_click_on_the_guidance_link
    click_link 'Read how the application process works'
  end

  def then_i_am_taken_to_the_guidance_page
    expect(page).to have_current_path(candidate_interface_guidance_path)
  end
end

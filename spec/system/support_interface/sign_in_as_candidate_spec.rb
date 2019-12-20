require 'rails_helper'

RSpec.feature 'Sign in as candidate' do
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(Time.zone.local(2019, 12, 16)) do
      example.run
    end
  end

  scenario 'Support user signs in as a candidate' do
    given_i_am_a_support_user
    and_the_edit_application_feature_flag_is_on
    and_there_is_an_unsubmitted_application
    when_i_visit_the_unsubmitted_application_form_page
    and_click_the_sign_in_button
    then_i_am_logged_in_as_the_candidate
    and_i_see_the_your_application_page

    given_there_is_an_amendable_application
    when_i_visit_the_amendable_application_form_page
    and_click_the_sign_in_button
    then_i_am_logged_in_as_the_candidate
    and_i_see_the_edit_application_page

    given_there_is_an_awaiting_provider_decision_application
    when_i_visit_the_awaiting_provider_decision_application_form_page
    and_click_the_sign_in_button
    then_i_am_logged_in_as_the_candidate
    and_i_see_the_application_dashboard
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def and_there_is_an_unsubmitted_application
    @unsubmitted_application = create(:completed_application_form, submitted_at: nil)
  end

  def when_i_visit_the_unsubmitted_application_form_page
    visit support_interface_application_form_path(@unsubmitted_application)
  end

  def and_click_the_sign_in_button
    click_on 'Sign in as this candidate'
  end

  def then_i_am_logged_in_as_the_candidate
    expect(page).to have_content 'You are now signed in as candidate'
  end

  def and_i_see_the_your_application_page
    within('.govuk-heading-xl') do
      expect(page).to have_content t('page_titles.application_form')
    end
  end

  def given_there_is_an_amendable_application
    @amendable_application = create(:completed_application_form, submitted_at: Time.zone.local(2019, 12, 16))
    create(:application_choice, status: :application_complete, edit_by: Time.zone.local(2019, 12, 20), application_form: @amendable_application)
  end

  def when_i_visit_the_amendable_application_form_page
    visit support_interface_application_form_path(@amendable_application)
  end

  def and_i_see_the_edit_application_page
    within('.govuk-heading-xl') do
      expect(page).to have_content t('page_titles.edit_application_form')
    end
  end

  def given_there_is_an_awaiting_provider_decision_application
    @awaiting_provider_decision_application = create(:completed_application_form, submitted_at: Time.zone.local(2019, 12, 2))
    create(:application_choice, status: :awaiting_provider_decision, edit_by: Time.zone.local(2019, 12, 9), application_form: @awaiting_provider_decision_application)
  end

  def when_i_visit_the_awaiting_provider_decision_application_form_page
    visit support_interface_application_form_path(@awaiting_provider_decision_application)
  end

  def and_i_see_the_application_dashboard
    within('.govuk-heading-xl') do
      expect(page).to have_content t('page_titles.application_dashboard')
    end
  end
end

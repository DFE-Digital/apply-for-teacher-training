require 'rails_helper'

RSpec.feature 'A candidate edits their application' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Time.zone.local(2019, 12, 16)) do
      example.run
    end
  end

  scenario 'candidate selects to edit their application', sidekiq: true do
    given_the_edit_application_feature_flag_is_on
    and_i_am_signed_in_as_a_candidate
    and_i_have_a_completed_application

    when_i_visit_the_application_dashboard
    and_i_click_the_edit_link
    then_i_see_a_button_to_edit_my_application

    when_i_click_the_edit_button
    then_i_see_the_edit_application_page
    and_i_see_the_remaining_days_to_edit
  end

  def given_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def and_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_a_completed_application
    form = create(:completed_application_form, :with_completed_references, :without_application_choices, candidate: current_candidate, submitted_at: Time.zone.local(2019, 12, 16))
    create(:application_choice, status: :application_complete, edit_by: Time.zone.local(2019, 12, 20), application_form: form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_the_edit_link
    click_link t('application_complete.dashboard.edit_link')
  end

  def then_i_see_a_button_to_edit_my_application
    expect(page).to have_link(t('application_complete.edit_page.edit_button'))
  end

  def when_i_click_the_edit_button
    click_link t('application_complete.edit_page.edit_button')
  end

  def then_i_see_the_edit_application_page
    within('.govuk-heading-xl') do
      expect(page).to have_content(t('page_titles.edit_application_form'))
    end
  end

  def and_i_see_the_remaining_days_to_edit
    remaining_days_to_edit = t(
      'application_complete.edit_page.warning_text',
      remaining_days: '4 days',
      date: '20 December 2019',
    )

    expect(page).to have_content(remaining_days_to_edit)
  end
end

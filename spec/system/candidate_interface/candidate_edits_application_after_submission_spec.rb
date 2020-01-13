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

    when_i_visit_the_application_dashboard
    then_i_should_see_my_unsubmitted_application

    given_i_have_a_completed_application
    when_i_visit_the_application_dashboard
    and_i_click_the_edit_link
    then_i_see_a_button_to_edit_my_application

    when_i_click_the_edit_button
    then_i_see_the_edit_application_page
    and_i_see_the_remaining_days_to_edit
    and_i_see_the_submit_button_is_changed
    and_i_see_i_cant_change_my_references
    and_i_see_a_submitted_label_for_referees

    when_i_click_on_referees
    then_i_can_review_my_references
    and_i_cannot_see_the_edit_or_delete_referee_links

    when_i_visit_the_new_referee_page
    then_i_see_the_review_referees_page

    when_the_amend_period_has_ended_and_i_visit_the_edit_application_page
    then_i_see_the_application_dashboard
  end

  def given_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def and_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def given_i_have_a_completed_application
    current_candidate.current_application.destroy! # Destroy the unsubmitted one that was created earlier for simplicity.
    @form = create(:completed_application_form, :with_completed_references, :without_application_choices, candidate: current_candidate, submitted_at: Time.zone.local(2019, 12, 16))
    create(:application_choice, status: :application_complete, edit_by: Time.zone.local(2019, 12, 20), application_form: @form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_should_see_my_unsubmitted_application
    expect(page).to have_content(t('page_titles.application_form'))
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

  def and_i_see_i_cant_change_my_references
    expect(page).to have_content(t('application_complete.edit_page.references_uneditable'))
  end

  def and_i_see_a_submitted_label_for_referees
    within('#referees-badge-id') { expect(page).to have_content('Submitted') }
  end

  def when_i_click_on_referees
    click_link 'Referees'
  end

  def then_i_can_review_my_references
    first_referee = @form.application_references.first
    second_referee = @form.application_references.second

    expect(page).to have_content(first_referee.name)
    expect(page).to have_content(second_referee.name)
  end

  def and_i_cannot_see_the_edit_or_delete_referee_links
    expect(page).not_to have_content('Change')
    expect(page).not_to have_content(t('application_form.referees.delete'))
  end

  def when_i_visit_the_new_referee_page
    visit candidate_interface_new_referee_path
  end

  def then_i_see_the_review_referees_page
    then_i_can_review_my_references
  end

  def when_the_amend_period_has_ended_and_i_visit_the_edit_application_page
    Timecop.travel(Time.zone.local(2019, 12, 16) + 5.days) do
      visit candidate_interface_application_form_path
    end
  end

  def then_i_see_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
  end

  def and_i_see_the_submit_button_is_changed
    expect(page).to have_content(t('application_complete.edit_page.resubmit_title'))
    expect(page).to have_link(t('application_complete.edit_page.resubmit_button'))
  end
end

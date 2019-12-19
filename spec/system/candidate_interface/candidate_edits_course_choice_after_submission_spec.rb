require 'rails_helper'

RSpec.feature 'A candidate edits their course choice after submission' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Time.zone.local(2019, 12, 16)) do
      example.run
    end
  end

  scenario 'candidate deletes their course choice', sidekiq: true do
    given_the_edit_application_feature_flag_is_on
    and_i_am_signed_in_as_a_candidate
    and_i_have_a_completed_application

    when_i_visit_the_application_dashboard
    and_i_click_the_edit_link
    then_i_see_a_button_to_edit_my_application

    when_i_click_the_edit_button
    then_i_see_the_edit_application_page

    when_i_click_course_choices
    then_i_can_delete_my_course_choices

    when_i_click_the_delete_course_link
    then_i_see_the_delete_confirmation_page

    when_i_click_the_confirm_button
    then_i_see_that_the_course_choice_is_deleted
  end

  def given_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def and_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_a_completed_application
    form = create(:completed_application_form, :with_completed_references, :without_application_choices, candidate: current_candidate, submitted_at: Time.zone.local(2019, 12, 16))
    @application_choice = create(:application_choice, status: :awaiting_references, edit_by: Time.zone.local(2019, 12, 20), application_form: form)
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

  def when_i_click_course_choices
    click_link t('page_titles.course_choices')
  end

  def then_i_can_delete_my_course_choices
    expect(page).to have_link t('application_form.courses.delete')
  end

  def when_i_click_the_delete_course_link
    click_link t('application_form.courses.delete')
  end

  def then_i_see_the_delete_confirmation_page
    expect(page).to have_content(t('page_titles.destroy_course_choice'))
  end

  def when_i_click_the_confirm_button
    click_button t('application_form.courses.confirm_delete')
  end

  def then_i_see_that_the_course_choice_is_deleted
    expect(page).not_to have_content(@application_choice.provider.name)
    expect(page).not_to have_content(@application_choice.course_option.course.name)
    expect(page).not_to have_content(@application_choice.course_option.site.name)
  end
end

require 'rails_helper'

RSpec.feature 'Change course choice' do
  include DfESignInHelpers

  scenario 'Change the course choice on an application form', with_audited: true do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    then_i_see_a_change_course_choice_link

    when_i_click_change_course_choice
    then_i_see_a_confirmation_page_prompting_for_course_details

    when_i_click_continue
    then_i_see_a_validation_error

    when_i_enter_the_new_course_choice_and_press_change
    then_i_see_the_application_page
    and_the_new_course_choice
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_see_a_change_course_choice_link
    expect(page).to have_link('Change course choice')
  end

  def when_i_click_change_course_choice
    click_link('Change course choice')
  end

  def then_i_see_a_confirmation_page_prompting_for_course_details
    expect(page).to have_current_path(
      support_interface_application_form_change_course_choice_path(
        application_form_id: @application_choice.application_form_id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_content('Change a course choice')
  end

  def when_i_click_continue
    click_on 'Change'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(
      support_interface_application_form_change_course_choice_path(
        application_form_id: @application_choice.application_form_id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_content('Please enter a provider code')
    expect(page).to have_content('Please enter a course code')
    expect(page).to have_content('Select a study mode option')
    expect(page).to have_content('Please enter a site code')
    expect(page).to have_content('Enter a Zendesk ticket URL')
    expect(page).to have_content('Select that you have read the guidance')
  end

  def when_i_enter_the_new_course_choice_and_press_change
    @course_option = create(:course_option, study_mode: :full_time)

    fill_in 'Provider code', with: @course_option.course.provider.code
    fill_in 'Course code', with: @course_option.course.code
    choose 'Full time'
    fill_in 'Site code', with: @course_option.site.code
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/123'
    check 'I have read the guidance'
    click_on 'Change'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(support_interface_application_form_path(@application_choice.application_form_id))
  end

  def and_the_new_course_choice
    expect(page).to have_content 'Course successfully changed'
    expect(page).to have_content @course_option.course.name
    expect(page).to have_content @course_option.provider.name
    expect(page).to have_content @course_option.course.study_mode
    expect(page).to have_content @course_option.site.name
  end
end

require 'rails_helper'

RSpec.describe 'Add course to submitted application' do
  include DfESignInHelpers

  before do
    given_i_am_a_support_user
    and_there_is_a_submitted_application_in_the_system_with_an_accepted_offer
    and_i_visit_the_support_page
    when_i_click('Alice Wunder')
  end

  scenario 'Support user adds course to submitted application with different provider' do
    @new_option = create(:course_option, :full_time)
    when_i_click('Change course choice')
    then_i_see_the_change_course_choice_page

    when_i_enter_new_choice_details
    and_i_click('Change')

    then_i_see_error('Confirm that you want to change the provider. This should only be done in exceptional circumstances')
    when_i_check('I confirm I want to move the candidate to a course with a different provider.')

    and_i_click('Change')
    then_the_course_has_been_changed
  end

  scenario 'Support user changes offered course for a submitted application to a course with no vacancies' do
    @new_option = create(
      :course_option,
      :full_time,
      :no_vacancies,
      course: build(:course, provider: @application_choice.provider),
    )
    when_i_click('Change course choice')
    when_i_enter_new_choice_details
    and_i_click('Change')
    then_i_see_the_no_vacancies_warning

    when_i_check('I confirm that I would like to move the candidate to a course with no vacancies')
    and_i_click('Change')
    then_the_course_has_been_changed
  end

  scenario 'Support user changes course to one with vacancies, same provider' do
    @new_option = create(
      :course_option,
      :full_time,
      course: build(:course, provider: @application_choice.provider),
    )
    when_i_click('Change course choice')
    when_i_enter_new_choice_details
    and_i_click('Change')
    then_the_course_has_been_changed
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application_in_the_system_with_an_accepted_offer
    @application_form = create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder')
    @application_choice = create(:application_choice, :accepted, application_form: @application_form)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_see_the_change_course_choice_page
    expect(page).to have_text 'Change a course choice'
  end

  def when_i_enter_new_choice_details
    fill_in 'Provider code', with: @new_option.course.provider.code
    fill_in 'Course code', with: @new_option.course.code
    choose 'Full time'
    fill_in 'Site code', with: @new_option.site.code
    choose @new_option.course.recruitment_cycle_year
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
    check 'I have read the guidance'
  end

  def then_i_see_the_no_vacancies_warning
    within('div.govuk-notification-banner__content') do
      expect(page).to have_text 'Are you sure you want to move the candidate to a course with no vacancies? Please check the box'
    end
  end

  def then_i_see_error(text)
    expect(page).to have_text(text).twice

    within('div.govuk-error-summary') do
      expect(page).to have_text('There is a problem')
      expect(page).to have_text(text)
    end
  end

  def when_i_check(text)
    check(text)
  end

  def and_i_click(text)
    click_on text
  end
  alias_method :when_i_click, :and_i_click

  def then_the_course_has_been_changed
    expect(page).to have_text 'Course successfully changed'
  end
end

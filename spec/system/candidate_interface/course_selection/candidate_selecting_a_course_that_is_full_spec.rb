require 'rails_helper'

RSpec.feature 'Selecting a full course', continuous_applications: false do
  include CandidateHelper

  scenario 'Candidate selects a full course' do
    given_i_am_signed_in
    and_there_is_a_full_course
    when_i_select_the_full_course
    then_i_see_a_page_telling_me_i_cannot_apply
    and_i_click_the_choose_another_course_link
    then_i_should_be_on_the_course_choices_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_is_a_full_course
    @course = create(:course, :open_on_apply)

    create(:course_option, course: @course, vacancy_status: 'no_vacancies')
    create(:course_option, course: @course, vacancy_status: 'vacancies', site_still_valid: false)
  end

  def when_i_select_the_full_course
    visit candidate_interface_application_form_path
    click_link 'Choose your courses'

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select @course.provider.name
    click_button t('continue')

    expect(page).to have_text("#{@course.name_and_code} – No vacancies")

    choose @course.name
    click_button t('continue')
  end

  def then_i_see_a_page_telling_me_i_cannot_apply
    expect(page).to have_text('You cannot apply to this course because it has no vacancies')
    expect(page).to have_text("The course ‘#{@course.name_and_code}’ is full")
  end

  def and_i_click_the_choose_another_course_link
    click_link 'choose another course'
  end

  def then_i_should_be_on_the_course_choices_page
    expect(page).to have_current_path(candidate_interface_course_choices_choose_path)
  end
end

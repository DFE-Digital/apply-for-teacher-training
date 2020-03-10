require 'rails_helper'

RSpec.describe 'Selecting a full course' do
  include CandidateHelper

  scenario 'Candidate selects a full course' do
    given_i_am_signed_in
    and_there_is_a_full_course
    when_i_select_the_full_course
    then_i_see_a_page_telling_me_i_cannot_apply
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_is_a_full_course
    @course = create(:course, :open_on_apply)

    create(:course_option, course: @course, vacancy_status: 'no_vacancies')
  end

  def when_i_select_the_full_course
    visit candidate_interface_application_form_path
    click_link 'Course choices'
    click_link 'Continue'

    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select @course.provider.name
    click_button 'Continue'

    choose @course.name
    click_button 'Continue'
  end

  def then_i_see_a_page_telling_me_i_cannot_apply
    expect(page).to have_text('You cannot apply to this course because it has no vacancies')
    expect(page).to have_text("The course '#{@course.name_and_code}' is full")
  end
end

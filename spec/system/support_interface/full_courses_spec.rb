require 'rails_helper'

RSpec.describe 'Full courses' do
  include DfESignInHelpers

  scenario 'View all course options that are full' do
    given_i_am_a_support_user
    and_there_are_courses_without_vacancies
    when_i_visit_the_course_options_page
    then_i_see_the_list_of_course_options
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_courses_without_vacancies
    create(:course_option, vacancy_status: 'no_vacancies')
  end

  def when_i_visit_the_course_options_page
    visit support_interface_course_options_path
  end

  def then_i_see_the_list_of_course_options
    expect(page).to have_content 'No vacancies'
  end
end

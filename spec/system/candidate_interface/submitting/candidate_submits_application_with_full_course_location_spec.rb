require 'rails_helper'

RSpec.feature 'Candidate submits the application with full course choice location' do
  include CandidateHelper

  scenario 'The location that the candidate picked is full but others have vacancies' do
    given_i_complete_my_application
    and_the_selected_course_options_is_now_full
    and_an_alternative_course_option_has_vacancies
    and_i_submit_my_application

    then_i_see_a_warning_that_there_are_no_vacancies_at_my_chosen_location
    and_i_cannot_proceed
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_the_selected_course_options_is_now_full
    course_option = current_candidate.current_application.application_choices.first.course_option
    course_option.update!(vacancy_status: 'no_vacancies')
  end

  def and_an_alternative_course_option_has_vacancies
    alternative_site = create(:site, name: 'Alternative site', code: 'B', provider: @provider)
    create(
      :course_option,
      site: alternative_site,
      course: current_candidate.current_application.application_choices.first.course,
    )
  end

  def and_i_submit_my_application
    click_link 'Check and submit your application'
  end

  def then_i_see_a_warning_that_there_are_no_vacancies_at_my_chosen_location
    expect(page).to have_content("Your chosen location for ‘#{current_candidate.current_application.application_choices.first.course.provider_and_name_code}’ has no vacancies")
  end

  def and_i_cannot_proceed
    click_link t('continue')
    expect(page).to have_content('There is a problem')
    expect(page).to have_content("Your chosen location for ‘#{current_candidate.current_application.application_choices.first.course.provider_and_name_code}’ has no vacancies")
  end
end

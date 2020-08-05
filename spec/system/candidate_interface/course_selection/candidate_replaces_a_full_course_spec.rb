require 'rails_helper'

RSpec.feature 'Selecting a course' do
  include CandidateHelper

  scenario 'Candidate selects a course choice' do
    given_i_have_submitted_my_application
    and_one_of_my_application_choices_has_become_full
    and_there_are_course_options

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    and_i_choose_to_replace_my_course
    then_i_see_the_have_you_chosen_page

    when_i_choose_that_i_do_not_know_where_i_want_to_apply
    then_i_see_the_go_to_find_page

    when_i_click_back
    then_i_see_the_have_you_chosen_page

    when_i_choose_that_i_know_where_i_want_to_apply
    then_i_see_the_pick_replacment_provider_page

    when_i_choose_a_provider_with_no_courses_on_ucas
    then_i_see_the_replace_course_choice_ucas_no_courses_page

    when_i_click_back
    then_i_see_the_pick_replacment_provider_page

    when_i_choose_a_provider
    then_i_should_see_a_course_and_its_description

    when_submit_without_choosing_a_course
    then_i_should_see_an_error

    when_i_choose_a_course_on_ucas_but_not_on_apply
    then_i_see_the_replace_course_choice_ucas_with_course_page

    when_i_click_back
    then_i_see_the_pick_replacment_course_page

    when_i_choose_a_course_that_is_full
    then_i_see_the_replace_course_choice_full_page

    when_i_click_back
    then_i_see_the_pick_replacment_course_page

    when_i_choose_a_course
    then_i_see_the_pick_replacement_study_mode_page

    when_i_choose_full_time
    then_i_see_the_replace_location_page

    when_i_choose_a_location
    then_i_see_the_confirm_replacement_page

    when_i_click_back
    then_i_see_the_replace_location_page

    when_i_choose_a_location
    and_i_click_replace_course_choice
    then_i_arrive_at_my_application_dashboard
    and_i_am_told_my_application_has_been_updated
    and_i_see_my_new_course_choice
    and_i_cannot_see_my_old_course_choice
  end

  def given_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
    @course_choice = @application.application_choices.first
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def and_there_are_course_options
    @provider = create(:provider)
    @course = create(:course, provider: @provider, exposed_in_find: true, open_on_apply: true, study_mode: 'full_time_or_part_time')
    @site = create(:site, provider: @provider)
    @site2 = create(:site, provider: @provider)
    @full_time_course_option = create(:course_option, :full_time, site: @site, course: @course)
    create(:course_option, :part_time, site: @site, course: @course)
    create(:course_option, site: @site2, course: @course)
    @provider_with_no_courses = create(:provider)
    @course_on_ucas = create(:course, exposed_in_find: true, open_on_apply: false, provider: @provider)
    @full_course = create(:course, provider: @provider, exposed_in_find: true, open_on_apply: true)
    create(:course_option, :no_vacancies, course: @course)
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def and_i_choose_to_replace_my_course
    choose 'Choose a different course'
    click_button 'Continue'
  end

  def then_i_see_the_have_you_chosen_page
    expect(page).to have_current_path candidate_interface_replace_course_choices_choose_path(@course_choice.id)
  end

  def when_i_choose_that_i_do_not_know_where_i_want_to_apply
    choose 'No, I need to find a course'
    click_button 'Continue'
  end

  def then_i_see_the_go_to_find_page
    expect(page).to have_content t('page_titles.find_a_course')
    expect(page).to have_current_path candidate_interface_replace_go_to_find_path(@course_choice.id)
  end

  def when_i_click_back
    click_link 'Back'
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def then_i_see_the_pick_replacment_provider_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_provider_path(@course_choice.id)
  end

  def when_i_choose_a_provider_with_no_courses_on_ucas
    select @provider_with_no_courses.name_and_code
    click_button 'Continue'
  end

  def then_i_see_the_replace_course_choice_ucas_no_courses_page
    expect(page).to have_content t('page_titles.apply_to_provider_on_ucas')
    expect(page).to have_current_path candidate_interface_replace_course_choice_ucas_no_courses_path(@course_choice.id, @provider_with_no_courses.id)
  end

  def when_i_choose_a_provider
    select @provider.name_and_code
    click_button 'Continue'
  end

  def then_i_should_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description)
  end

  def when_submit_without_choosing_a_course
    click_button 'Continue'
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'Select a course'
  end

  def when_i_choose_a_course_on_ucas_but_not_on_apply
    choose @course_on_ucas.name_and_code
    click_button 'Continue'
  end

  def then_i_see_the_replace_course_choice_ucas_with_course_page
    expect(page).to have_content t('page_titles.apply_to_course_on_ucas')
    expect(page).to have_current_path candidate_interface_replace_course_choice_ucas_with_course_path(@course_choice.id, @provider.id, @course_on_ucas.id)
  end

  def then_i_see_the_pick_replacment_course_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_course_path(@course_choice.id, @provider.id)
  end

  def when_i_choose_a_course_that_is_full
    choose @full_course.name_and_code
    click_button 'Continue'
  end

  def then_i_see_the_replace_course_choice_full_page
    expect(page).to have_content t('page_titles.full_course')
    expect(page).to have_current_path candidate_interface_replace_course_choice_full_path(@course_choice.id, @provider.id, @full_course.id)
  end

  def when_i_choose_a_course
    choose @course.name_and_code
    click_button 'Continue'
  end

  def then_i_see_the_pick_replacement_study_mode_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_study_mode_path(@course_choice.id, @provider.id, @course.id)
  end

  def when_i_choose_full_time
    choose 'Full time'
    click_button 'Continue'
  end

  def then_i_see_the_replace_location_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_location_path(@course_choice.id, @provider.id, @course.id, @full_time_course_option.study_mode)
  end

  def and_i_see_the_address
    expect(page).to have_content(@site.name_and_address)
  end

  def when_i_choose_a_location
    choose @site.name
    click_button 'Continue'
  end

  def then_i_see_the_confirm_replacement_page
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(
      @course_choice.id,
      @full_time_course_option.id,
      provider_id: @provider.id,
      course_id: @course.id,
      study_mode: @full_time_course_option.study_mode,
    )
  end

  def and_i_click_replace_course_choice
    click_link 'Replace course choice'
  end

  def then_i_arrive_at_my_application_dashboard
    expect(page).to have_current_path candidate_interface_application_complete_path
  end

  def and_i_am_told_my_application_has_been_updated
    expect(page).to have_content 'Your application has been successfully updated.'
  end

  def and_i_see_my_new_course_choice
    expect(page).to have_content @course.name
    expect(page).to have_content @site.name
  end

  def and_i_cannot_see_my_old_course_choice
    expect(page).not_to have_content @course_choice.site.name_and_address
  end
end

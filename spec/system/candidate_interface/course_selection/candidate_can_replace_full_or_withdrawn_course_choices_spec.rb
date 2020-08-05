require 'rails_helper'

RSpec.describe 'A course option selected by a candidate has become full or been withdrawn' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'when a candidate arrives at the dashboard they can follow the replace course flow' do
    given_i_have_submitted_my_application
    and_my_course_is_only_available_on_ucas

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    when_i_click_update_my_course_choice
    then_i_arrive_at_the_replace_course_choice_page

    when_i_choose_to_apply_through_ucas
    and_click_continue
    then_i_arrive_at_the_ucas_with_course_page

    given_the_course_becomes_available_on_apply
    and_one_of_my_application_choices_has_become_full
    and_there_is_another_location_available

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    when_i_click_update_my_course_choice
    then_i_arrive_at_the_replace_course_choice_page

    when_i_choose_submit_application_anyway
    and_click_continue
    then_i_arrive_at_my_dashboard

    given_i_have_two_full_course_choices

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_multiple_choices_are_not_available

    when_i_click_update_my_course_choice
    then_i_see_the_replace_course_choices_page
    and_i_see_my_first_course_choice
    and_i_see_my_second_course_choice

    when_i_click_continue_without_selecting_an_option
    then_i_am_told_i_need_to_select_a_course_choice

    when_i_choose_my_first_course_choice
    and_click_continue
    then_i_arrive_at_the_replace_course_choice_page
    and_i_see_my_first_course_choice

    when_i_click_continue_without_selecting_an_option
    then_i_am_told_i_need_to_select_an_option

    when_i_choose_submit_application_anyway
    and_click_continue
    then_i_see_the_replace_course_choices_page

    when_i_choose_my_first_course_choice
    and_click_continue
    and_i_choose_to_add_a_new_location
    and_click_continue
    then_i_see_the_update_location_page
    and_i_can_see_my_another_choice_of_location

    when_i_click_continue_without_selecting_an_option
    then_i_am_told_i_need_to_select_a_location

    when_i_select_a_location
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page
    and_i_can_see_my_new_course_choice
    and_i_can_see_my_old_course_choice

    when_i_click_replace_course_choice
    then_i_arrive_at_my_dashboard
    and_i_can_see_my_new_course_choice
    and_i_cannot_see_my_old_course_choice

    given_my_course_choice_has_another_study_mode_option

    when_i_click_update_my_course_choice
    and_i_choose_to_study_part_time
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page_for_my_second_course_choice
    and_i_can_see_my_new_course_choices_study_mode
    and_i_can_see_my_old_course_choices_study_mode

    when_i_click_replace_course_choice
    then_i_arrive_at_my_dashboard
    and_my_new_course_choice_is_part_time

    given_my_new_course_choice_becomes_full

    given_there_is_a_provider_with_just_the_right_courses

    # @new_course
    when_i_choose_a_new_provider
    and_i_choose_a_new_course
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course
    and_i_can_see_my_new_course

    # @new_course_with_multiple_sites
    when_i_choose_a_new_provider
    and_click_continue
    and_i_choose_a_new_course_with_multiple_sites
    and_click_continue
    and_i_choose_a_new_location
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_sites
    and_i_can_see_my_new_course_with_multiple_sites

    # @new_course_with_multiple_study_modes
    when_i_choose_a_new_provider
    and_click_continue
    and_i_choose_a_new_course_with_multiple_study_modes
    and_click_continue
    and_i_choose_a_new_study_mode
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_study_modes
    and_i_can_see_my_new_course_with_multiple_study_modes

    # @new_course_with_multiple_sites_and_study_modes
    when_i_choose_a_new_provider
    and_click_continue
    and_i_choose_a_new_course_with_multiple_sites_and_study_modes
    and_click_continue
    and_i_choose_a_new_study_mode
    and_click_continue
    and_i_choose_a_new_location
    and_click_continue
    then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_sites_and_study_modes
    and_i_can_see_my_new_course_with_multiple_sites_and_study_modes
  end

  def given_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
    @course_option = @application.application_choices.first.course_option
  end

  def and_my_course_is_only_available_on_ucas
    @removed_course = @application.application_choices.first.course
    @removed_course.update!(open_on_apply: false)
  end

  def when_i_choose_to_apply_through_ucas
    choose 'Apply for this course through UCAS'
  end

  def then_i_arrive_at_the_ucas_with_course_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_ucas_with_course_path(
      @application.application_choices.first.id,
      @removed_course.provider.id,
      @removed_course.id,
      choose_action: true,
    )
  end

  def given_the_course_becomes_available_on_apply
    @removed_course.update!(open_on_apply: true)
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option.no_vacancies!
  end

  def and_there_is_another_location_available
    @site = create(:site, provider: @course_option.provider)
    @course_option2 = create(:course_option, site: @site, course: @course_option.course)
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_that_one_of_my_choices_in_not_available
    expect(page).to have_content 'One of your choices is not available anymore.'
  end

  def given_i_have_two_full_course_choices
    course_option_for_provider(provider: @course_option.provider)
    @application_choice = create(:application_choice, application_form: @application, status: 'awaiting_references')
    @application_choice.course_option.no_vacancies!
  end

  def then_i_see_that_multiple_choices_are_not_available
    expect(page).to have_content 'Some of your choices are not available anymore.'
  end

  def when_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def then_i_see_the_replace_course_choices_page
    expect(page).to have_current_path candidate_interface_replace_course_choices_path
  end

  def when_i_choose_submit_application_anyway
    choose 'Keep this course choice anyway'
  end

  def and_i_see_my_first_course_choice
    expect(page).to have_content(@course_option.course.name_and_code)
  end

  def and_i_see_my_second_course_choice
    expect(page).to have_content(@application_choice.course.name_and_code)
  end

  def when_i_click_continue_without_selecting_an_option
    click_button 'Continue'
  end

  def then_i_am_told_i_need_to_select_a_course_choice
    expect(page).to have_content 'Please select a course choice to update.'
  end

  def when_i_choose_my_first_course_choice
    choose "#{@course_option.provider.name} – #{@course_option.course.name_and_code}"
  end

  def and_click_continue
    when_i_click_continue_without_selecting_an_option
  end

  def then_i_arrive_at_the_replace_course_choice_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_path(@course_option.application_choices.first.id)
  end

  def then_i_am_told_i_need_to_select_an_option
    expect(page).to have_content 'Please select an option to update your course choice.'
  end

  def and_i_choose_to_add_a_new_location
    choose 'Choose a different location'
  end

  def then_i_see_the_update_location_page
    expect(page).to have_content t('page_titles.which_location')
  end

  def and_i_can_see_my_another_choice_of_location
    expect(page).to have_content @course_option2.site.full_address
  end

  def then_i_am_told_i_need_to_select_a_location
    expect(page).to have_content 'Please select a new location.'
  end

  def when_i_select_a_location
    choose @course_option2.site.name
  end

  def then_i_see_the_confirm_replacement_course_choice_page
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(@course_option.application_choices.first.id, @course_option2.id)
  end

  def when_i_click_replace_course_choice
    click_link 'Replace course choice'
  end

  def then_i_arrive_at_my_dashboard
    expect(page).to have_current_path candidate_interface_application_complete_path
  end

  def and_i_can_see_my_new_course_choice
    expect(page).to have_content @course_option2.site.full_address
  end

  def and_i_can_see_my_old_course_choice
    expect(page).to have_content @course_option.site.full_address
  end

  def and_i_cannot_see_my_old_course_choice
    expect(page).not_to have_content @course_option.site.full_address
  end

  def given_my_course_choice_has_another_study_mode_option
    @part_time_course_option = create(:course_option, :part_time, site: @application_choice.course_option.site, course: @application_choice.course_option.course)
    @application_choice.course.update!(study_mode: 'full_time_or_part_time')
  end

  def and_i_choose_to_study_part_time
    choose 'Study part time instead'
  end

  def then_i_see_the_confirm_replacement_course_choice_page_for_my_second_course_choice
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(@application_choice.id, @part_time_course_option.id)
  end

  def and_i_can_see_my_new_course_choices_study_mode
    expect(page).to have_content @part_time_course_option.study_mode.humanize
  end

  def and_i_can_see_my_old_course_choices_study_mode
    expect(page).to have_content @application_choice.course_option.study_mode.humanize
  end

  def and_my_new_course_choice_is_part_time
    expect(page).to have_content @part_time_course_option.study_mode.humanize
  end

  def given_my_new_course_choice_becomes_full
    @part_time_course_option.no_vacancies!
  end

  def given_there_is_a_provider_with_just_the_right_courses
    @new_provider = create(:provider, :with_signed_agreement)
    @site1 = create(:site, provider: @new_provider)
    @site2 = create(:site, provider: @new_provider)

    @new_course = create(:course, :open_on_apply, provider: @new_provider)
    create(:course_option, site: @site1, course: @new_course)

    @new_course_with_multiple_sites = create(:course, :open_on_apply, provider: @new_provider)
    create(:course_option, site: @site1, course: @new_course_with_multiple_sites)
    create(:course_option, site: @site2, course: @new_course_with_multiple_sites)

    @new_course_with_multiple_study_modes = create(:course, :with_both_study_modes, :open_on_apply, provider: @new_provider)
    create(:course_option, :full_time, site: @site1, course: @new_course_with_multiple_study_modes)
    create(:course_option, :part_time, site: @site1, course: @new_course_with_multiple_study_modes)

    @new_course_with_multiple_sites_and_study_modes = create(:course, :with_both_study_modes, :open_on_apply, provider: @new_provider)
    create(:course_option, :full_time, site: @site1, course: @new_course_with_multiple_sites_and_study_modes)
    create(:course_option, :full_time, site: @site2, course: @new_course_with_multiple_sites_and_study_modes)
    create(:course_option, :part_time, site: @site1, course: @new_course_with_multiple_sites_and_study_modes)
    create(:course_option, :part_time, site: @site2, course: @new_course_with_multiple_sites_and_study_modes)
  end

  def when_i_choose_a_new_provider
    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    when_i_click_update_my_course_choice
    and_i_choose_a_different_course
    and_click_continue
    and_i_know_where_i_want_to_apply
    and_click_continue
    and_i_choose_a_new_provider
    and_click_continue
  end

  def and_i_choose_a_different_course
    choose 'Choose a different course'
  end

  def and_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
  end

  def and_i_choose_a_new_provider
    select @new_provider.name_and_code
  end

  def and_i_choose_a_new_course
    choose @new_course.name_and_code
  end

  def and_i_choose_a_new_location
    choose @site1.name
  end

  def and_i_choose_a_new_study_mode
    choose 'Full time'
  end

  def and_i_choose_a_new_course_with_multiple_sites
    choose @new_course_with_multiple_sites.name_and_code
  end

  def and_i_choose_a_new_course_with_multiple_study_modes
    choose @new_course_with_multiple_study_modes.name_and_code
  end

  def and_i_choose_a_new_course_with_multiple_sites_and_study_modes
    choose @new_course_with_multiple_sites_and_study_modes.name_and_code
  end

  def then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(
      @application.application_choices.last.id,
      @new_course.course_options.first.id,
      provider_id: @new_provider.id,
    )
  end

  def then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_sites
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(
      @application.application_choices.last.id,
      @new_course_with_multiple_sites.course_options.first.id,
      provider_id: @new_provider.id,
      course_id: @new_course_with_multiple_sites.id,
      study_mode: 'full_time',
    )
  end

  def then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_study_modes
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(
      @application.application_choices.last.id,
      @new_course_with_multiple_study_modes.course_options.first.id,
      provider_id: @new_provider.id,
      course_id: @new_course_with_multiple_study_modes.id,
      study_mode: 'full_time',
    )
  end

  def then_i_see_the_confirm_replacement_course_choice_page_for_my_new_course_with_multiple_sites_and_study_modes
    expect(page).to have_current_path candidate_interface_confirm_replacement_course_choice_path(
      @application.application_choices.last.id,
      @new_course_with_multiple_sites_and_study_modes.course_options.first.id,
      provider_id: @new_provider.id,
      course_id: @new_course_with_multiple_sites_and_study_modes.id,
      study_mode: 'full_time',
    )
  end

  def and_i_can_see_my_new_course
    expect(page).to have_content @new_course.name
  end

  def and_i_can_see_my_new_course_with_multiple_sites
    expect(page).to have_content @new_course_with_multiple_sites.name
    expect(page).to have_content @site1.name
  end

  def and_i_can_see_my_new_course_with_multiple_study_modes
    expect(page).to have_content @new_course_with_multiple_study_modes.name
    expect(page).to have_content 'Full time'
  end

  def and_i_can_see_my_new_course_with_multiple_sites_and_study_modes
    expect(page).to have_content @new_course_with_multiple_sites_and_study_modes.name
    expect(page).to have_content @site1.name
    expect(page).to have_content 'Full time'
  end
end

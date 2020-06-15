require 'rails_helper'

RSpec.describe 'Candidate replacing a full or withdrawn course option post submitting their application' do
  include CandidateHelper
  scenario 'they are only presented with valid choices on the choose replacement action page' do
    given_the_replace_full_or_withdrawn_application_choices_is_active
    and_i_have_submitted_my_application
    and_my_application_choice_has_become_full_and_no_other_study_modes_or_locations_available

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    then_i_arrive_on_the_replace_course_choice_page
    and_i_should_be_told_the_course_is_full
    and_i_should_have_the_option_to_replace_my_course_choice
    and_i_should_have_the_option_to_delete_my_course_choice
    and_i_should_have_the_option_to_keep_my_course_choice
    and_i_should_not_have_the_option_to_change_the_location_of_my_course_choice
    and_i_should_not_have_the_option_to_replace_the_study_mode_course_choice

    given_that_there_is_another_location_and_study_mode_available

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    then_i_arrive_on_the_replace_course_choice_page
    and_i_should_be_told_there_are_no_more_full_time_places_at_my_location
    and_i_should_have_the_option_to_replace_my_course_choice
    and_i_should_have_the_option_to_delete_my_course_choice
    and_i_should_have_the_option_to_keep_my_course_choice
    and_i_should_have_the_option_to_change_the_location_of_my_course_choice
    and_i_should_have_the_option_to_replace_the_study_mode_course_choice

    given_the_other_study_mode_becomes_full

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    then_i_arrive_on_the_replace_course_choice_page
    and_i_should_be_told_there_are_no_more_places_at_that_location_available
    and_i_should_have_the_option_to_replace_my_course_choice
    and_i_should_have_the_option_to_delete_my_course_choice
    and_i_should_have_the_option_to_keep_my_course_choice
    and_i_should_have_the_option_to_change_the_location_of_my_course_choice
    and_i_should_not_have_the_option_to_replace_the_study_mode_course_choice

    given_that_part_time_study_mode_becomes_available_and_all_other_locations_become_full

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    then_i_arrive_on_the_replace_course_choice_page
    and_i_should_be_told_there_are_no_more_full_time_places_available
    and_i_should_have_the_option_to_replace_my_course_choice
    and_i_should_have_the_option_to_delete_my_course_choice
    and_i_should_have_the_option_to_keep_my_course_choice
    and_i_should_not_have_the_option_to_change_the_location_of_my_course_choice
    and_i_should_have_the_option_to_replace_the_study_mode_course_choice

    given_the_course_has_been_withdrawn

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    then_i_arrive_on_the_replace_course_choice_page
    and_i_should_be_told_that_the_course_has_been_withdrawn
    and_i_should_have_the_option_to_replace_my_course_choice
    and_i_should_have_the_option_to_delete_my_course_choice
    and_i_should_have_the_option_to_keep_my_course_choice
    and_i_should_not_have_the_option_to_change_the_location_of_my_course_choice
    and_i_should_not_have_the_option_to_replace_the_study_mode_course_choice
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_my_application_choice_has_become_full_and_no_other_study_modes_or_locations_available
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def then_i_arrive_on_the_replace_course_choice_page
    expect(page).to have_current_path candidate_interface_replace_course_choice_path(@course_option.application_choices.first.id)
  end

  def and_i_should_be_told_the_course_is_full
    expect(page).to have_content "#{@course_option.course.name_and_code} is now full."
  end

  def and_i_should_have_the_option_to_replace_my_course_choice
    expect(page).to have_content('Choose a different course')
  end

  def and_i_should_have_the_option_to_delete_my_course_choice
    expect(page).to have_content('Remove course from application')
  end

  def and_i_should_have_the_option_to_keep_my_course_choice
    expect(page).to have_content('Submit application anyway')
  end

  def and_i_should_not_have_the_option_to_change_the_location_of_my_course_choice
    expect(page).not_to have_content('Choose a different location')
  end

  def and_i_should_not_have_the_option_to_replace_the_study_mode_course_choice
    expect(page).not_to have_content("Study #{@course_option.alternative_study_mode} instead")
  end

  def given_that_there_is_another_location_and_study_mode_available
    site = create(:site, provider: @course_option.provider)
    @second_location_course_option = create(:course_option, site: site, course: @course_option.course)
    @part_time_course_option = create(:course_option, site: @course_option.site, course: @course_option.course, study_mode: :part_time)
  end

  def and_i_should_have_the_option_to_change_the_location_of_my_course_choice
    expect(page).to have_content('Choose a different location')
  end

  def and_i_should_have_the_option_to_replace_the_study_mode_course_choice
    expect(page).to have_content("Study #{@course_option.alternative_study_mode.humanize.downcase} instead")
  end

  def and_i_should_be_told_there_are_no_more_full_time_places_at_my_location
    expect(page).to have_content("There are no more #{@course_option.study_mode.humanize.downcase} places for #{@course_option.course.name_and_code} at your choice of location.")
  end

  def given_the_other_study_mode_becomes_full
    @part_time_course_option.no_vacancies!
  end

  def and_i_should_be_told_there_are_no_more_places_at_that_location_available
    expect(page).to have_content("There are no more places at #{@course_option.site.name} for #{@course_option.course.name_and_code}.")
  end

  def given_that_part_time_study_mode_becomes_available_and_all_other_locations_become_full
    @part_time_course_option.vacancies!
    @second_location_course_option.no_vacancies!
  end

  def and_i_should_be_told_there_are_no_more_full_time_places_available
    expect(page).to have_content("There are no more #{@course_option.study_mode.humanize.downcase} places for #{@course_option.course.name_and_code}.")
  end

  def given_the_course_has_been_withdrawn
    @part_time_course_option.course.update!(withdrawn: true)
  end

  def and_i_should_be_told_that_the_course_has_been_withdrawn
    expect(page).to have_content("#{@course_option.course.name_and_code} is not running anymore.")
  end
end

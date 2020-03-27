require 'rails_helper'

RSpec.describe 'Candidate edits course choices' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'Candidate is signed in' do
    given_that_the_edit_course_choices_feature_flag_is_active
    and_i_am_signed_in
    and_there_is_a_course_with_one_course_option
    and_there_is_a_course_with_multiple_course_options

    when_i_visit_my_application_page
    and_i_click_on_course_choices
    and_i_click_on_add_course

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_single_site_course_as_my_first_course_choice
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_not_see_a_change_location_link

    when_i_click_to_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_multi_site_course_as_my_second_course_choice
    and_i_choose_the_first_site
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_first_site
    and_i_should_see_a_change_location_link

    when_i_click_to_change_the_location_of_the_second_course_choice
    and_i_choose_the_second_site
    then_i_should_be_on_the_course_choice_review_page
  end

  def given_that_the_edit_course_choices_feature_flag_is_active
    FeatureFlag.activate('edit_course_choices')
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_is_a_course_with_one_course_option
    @provider = create(:provider)
    create_list(:course, 2, provider: @provider, exposed_in_find: true, open_on_apply: true, study_mode: :full_time)
    course_option_for_provider(provider: @provider, course: @provider.courses.first)
  end

  def and_there_is_a_course_with_multiple_course_options
    course_option_for_provider(provider: @provider, course: @provider.courses.second)
    course_option_for_provider(provider: @provider, course: @provider.courses.second)
  end

  def when_i_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def and_i_click_on_add_course
    click_link 'Continue'
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def and_i_choose_a_provider
    select @provider.name_and_code
    click_button 'Continue'
  end

  def and_i_choose_the_single_site_course_as_my_first_course_choice
    choose @provider.courses.first.name_and_code
    click_button 'Continue'
  end

  def then_i_should_be_on_the_course_choice_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_not_see_a_change_location_link
    expect(page).not_to have_content("Change location for #{@provider.courses.first.name}")
  end

  def when_i_click_to_add_another_course
    click_link 'Add another course'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    when_i_choose_that_i_know_where_i_want_to_apply
  end

  def and_i_choose_the_multi_site_course_as_my_second_course_choice
    choose @provider.courses.second.name_and_code
    click_button 'Continue'
  end

  def and_i_choose_the_first_site
    choose @provider.courses.second.course_options.first.site.name
    click_button 'Continue'
  end

  def and_i_should_see_the_first_site
    expect(page).to have_content(@provider.courses.second.course_options.first.site.name)
  end

  def and_i_should_see_a_change_location_link
    expect(page).to have_content("Change location for #{@provider.courses.second.name}")
  end

  def when_i_click_to_change_the_location_of_the_second_course_choice
    click_link "Change location for #{@provider.courses.second.name}"
  end

  def and_i_choose_the_second_site
    choose @provider.courses.second.course_options.second.site.name
    click_button 'Continue'
  end

  def and_i_choose_the_updated_site_name
    expect(page).to have_content(@provider.courses.second.course_options.second.site.name)
  end
end

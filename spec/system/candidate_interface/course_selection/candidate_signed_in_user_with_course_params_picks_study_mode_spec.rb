require 'rails_helper'

RSpec.describe 'An existing candidate arriving from Find with course params selects a study mode' do
  include CourseOptionHelpers

  scenario 'Signed in user with Find course params selects a part time course' do
    given_the_pilot_is_open
    given_choosing_a_study_mode_is_active
    and_i_am_an_existing_candidate_on_apply
    and_the_course_i_selected_has_a_choice_of_study_modes
    and_i_am_signed_in

    when_i_arrive_at_the_apply_from_find_page_with_course_params
    and_i_click_apply_on_apply
    then_i_should_see_the_study_mode_page

    when_i_choose_the_part_time_course
    and_i_visit_my_course_choices_page
    then_i_should_see_it_on_my_review_page
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_choosing_a_study_mode_is_active
    FeatureFlag.activate('choose_study_mode')
  end

  def and_i_am_an_existing_candidate_on_apply
    @candidate = create(:candidate)
  end

  def and_the_course_i_selected_has_a_choice_of_study_modes
    @course = create(
      :course,
      :open_on_apply,
      :with_both_study_modes,
      name: 'Potions',
    )
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course, study_mode: :full_time)
    create(:course_option, site: @site, course: @course, study_mode: :part_time)
  end

  def and_i_am_signed_in
    login_as(@candidate)
  end

  def when_i_arrive_at_the_apply_from_find_page_with_course_params
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def and_i_click_apply_on_apply
    click_on t('apply_from_find.apply_button')
  end

  def then_i_should_see_the_study_mode_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_study_mode_path(
        @course.provider.id,
        @course.id,
      ),
    )
  end

  def when_i_choose_the_part_time_course
    choose 'Part time'
    click_button 'Continue'
  end

  def and_i_visit_my_course_choices_page
    visit candidate_interface_course_choices_review_path
  end

  def then_i_should_see_it_on_my_review_page
    expect(page).to have_content "#{@course.name} (#{@course.code})"
    expect(page).to have_content 'Part time'
    expect(page).to have_content @site.name
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end
end

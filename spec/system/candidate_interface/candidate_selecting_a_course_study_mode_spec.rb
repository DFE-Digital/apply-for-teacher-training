require 'rails_helper'

RSpec.feature 'Selecting a study mode' do
  include CandidateHelper

  scenario 'Candidate selects different study modes' do
    given_choosing_a_study_mode_is_active
    given_i_am_signed_in
    and_there_are_course_options

    when_i_select_a_part_time_course
    then_i_can_only_select_sites_with_a_part_time_course

    when_i_select_a_site
    then_i_see_my_course_choice

    given_there_is_a_single_site_full_time_course
    when_i_select_the_single_site_full_time_course
    then_the_site_is_resolved_automatically_and_i_see_the_course_choice
  end

  def given_there_is_a_single_site_full_time_course
    @third_site = create(:site, provider: @provider)

    @single_site_course = create(
      :course, :with_both_study_modes, :open_on_apply, provider: @provider, name: 'MS Painting'
    )

    create(
      :course_option,
      site: @third_site,
      course: @single_site_course,
      study_mode: :part_time,
    )

    create(
      :course_option,
      site: @third_site,
      course: @single_site_course,
      study_mode: :full_time,
    )
  end

  def when_i_select_the_single_site_full_time_course
    visit candidate_interface_application_form_path
    click_link 'Course choices'
    click_link 'Add another course'

    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select @provider.name
    click_button 'Continue'

    select @single_site_course.name
    click_button 'Continue'

    choose 'Full time'
    click_button 'Continue'
  end

  def then_the_site_is_resolved_automatically_and_i_see_the_course_choice
    expect(page).to have_text 'Course choices'
    expect(page).to have_text @single_site_course.name
    expect(page).to have_text 'Full time'
  end

  def given_choosing_a_study_mode_is_active
    FeatureFlag.activate('choose_study_mode')
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    @provider = create(:provider)

    @first_site = create(:site, provider: @provider)
    @second_site = create(:site, provider: @provider)
    @third_site = create(:site, provider: @provider)

    @course = create(
      :course, :with_both_study_modes, :open_on_apply, provider: @provider, name: 'Software Engineering'
    )

    create(
      :course_option,
      site: @first_site,
      course: @course,
      study_mode: :part_time,
    )
    create(
      :course_option,
      site: @second_site,
      course: @course,
      study_mode: :part_time,
    )
    create(
      :course_option,
      site: @third_site,
      course: @course,
      study_mode: :full_time,
    )
  end

  def when_i_select_a_part_time_course
    visit candidate_interface_application_form_path
    click_link 'Course choices'
    click_link 'Continue'

    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select @provider.name
    click_button 'Continue'

    select @course.name
    click_button 'Continue'

    click_button 'Continue'
    expect(page).to have_text "can't be blank"
    choose 'Part time'
    click_button 'Continue'
  end

  def then_i_can_only_select_sites_with_a_part_time_course
    expect(page).to have_text @first_site.name
    expect(page).to have_text @second_site.name
    expect(page).not_to have_text @third_site.name
  end

  def when_i_select_a_site
    choose @first_site.name
    click_button 'Continue'
  end

  def then_i_see_my_course_choice
    expect(page).to have_text 'Course choices'
    expect(page).to have_text @course.name
    expect(page).to have_text 'Part time'
  end
end

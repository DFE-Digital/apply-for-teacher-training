require 'rails_helper'

RSpec.feature 'Selecting a study mode' do
  include CandidateHelper

  scenario 'Candidate selects a part time course' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_select_a_part_time_course
    then_i_can_only_select_sites_with_a_part_time_course

    when_i_select_a_site
    then_i_see_my_course_choice
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    @provider = create(:provider)

    @first_site = create(:site, provider: @provider)
    @second_site = create(:site, provider: @provider)

    @course = create(
      :course, :with_both_study_modes, :open_on_apply, provider: @provider
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

    choose 'Part time'
    click_button 'Continue'
  end

  def then_i_can_only_select_sites_with_a_part_time_course
    expect(page).to have_text @first_site.name
    expect(page).not_to have_text @second_site.name
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

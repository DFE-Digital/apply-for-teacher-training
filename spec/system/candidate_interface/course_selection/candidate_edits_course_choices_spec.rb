require 'rails_helper'

RSpec.feature 'Candidate edits course choices', continuous_applications: false do
  include CandidateHelper
  include CourseOptionHelpers

  it 'Candidate is signed in' do
    given_i_am_signed_in
    and_there_is_a_course_with_one_course_option
    and_there_is_a_course_with_multiple_course_options
    and_there_is_a_course_with_both_study_modes_but_one_site

    when_i_visit_my_application_page
    and_i_click_on_course_choices

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_third_course_as_my_first_course_choice
    and_i_choose_the_full_time_study_mode
    then_i_should_see_the_review_page

    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_a_change_course_link

    when_i_click_to_change_the_course_for_the_first_course_choice
    and_i_choose_the_single_site_course_as_my_first_course_choice
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_updated_change_course_link
    and_i_should_not_see_a_change_location_link
    and_i_should_not_see_a_change_study_mode_link

    when_i_click_to_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_multi_site_course_as_my_second_course_choice
    and_i_choose_the_full_time_study_mode
    and_i_choose_the_first_site
    then_i_should_see_the_review_page

    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_first_site
    and_i_should_see_a_change_location_link
    and_i_should_see_a_change_study_mode_link

    when_i_click_to_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_single_site_course_as_my_third_course_choice
    and_i_choose_the_full_time_study_mode
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_another_change_study_mode_link
    and_i_should_not_see_another_change_location_link

    when_i_click_to_change_the_location_of_the_second_course_choice
    and_i_choose_the_second_site
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_updated_site

    when_i_click_to_change_the_study_mode_of_the_second_course_choice
    and_i_choose_part_time_study_mode
    and_i_am_asked_to_select_site
    and_i_choose_the_first_site_that_offers_part_time_study_mode
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_updated_study_mode_for_the_second_choice

    when_i_click_to_change_the_study_mode_of_the_third_course_choice
    and_i_choose_part_time_study_mode
    then_i_should_be_on_the_course_choice_review_page
    and_i_should_see_the_updated_study_mode_for_the_third_choice

    when_i_click_to_change_the_course_of_my_third_choice
    and_i_select_the_course_associated_with_my_second_choice
    then_i_am_told_that_i_have_already_added_that_course
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_is_a_course_with_one_course_option
    @provider = create(:provider)
    create(:course, :open_on_apply, name: 'English', provider: @provider, study_mode: :full_time)

    course_option_for_provider(provider: @provider, course: @provider.courses.first)
  end

  def and_there_is_a_course_with_multiple_course_options
    create(:course, :open_on_apply, :with_both_study_modes, name: 'Maths', provider: @provider)

    # Sites with full time study mode
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'full_time')

    # Sites with part time study mode
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'part_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'part_time')
  end

  def and_there_is_a_course_with_both_study_modes_but_one_site
    create(:course, :open_on_apply, :with_both_study_modes, name: 'Entomology', provider: @provider)

    site = create(:site, provider: @provider)

    course_option_for_provider(provider: @provider, course: @provider.courses.third, site:, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site:, study_mode: 'part_time')
  end

  def when_i_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Choose your courses'
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
  end

  def and_i_choose_a_provider
    select @provider.name_and_code
    click_button t('continue')
  end

  def and_i_choose_the_third_course_as_my_first_course_choice
    choose @provider.courses.third.name_and_code
    click_button t('continue')
  end

  def when_i_click_to_change_the_course_for_the_first_course_choice
    click_change_link "course choice for #{@provider.courses.third.name}"
  end

  def and_i_choose_the_single_site_course_as_my_first_course_choice
    choose @provider.courses.first.name_and_code
    click_button t('continue')
  end

  def then_i_should_be_on_the_course_choice_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_see_a_change_course_link
    expect(page).to have_content("Change course choice for #{@provider.courses.third.name}")
  end

  def and_i_should_see_the_updated_change_course_link
    expect(page).to have_content("Change course choice for #{@provider.courses.first.name}")
  end

  def and_i_should_not_see_a_change_location_link
    expect(page).not_to have_content("Change location for #{@provider.courses.first.name}")
  end

  def and_i_should_not_see_a_change_study_mode_link
    expect(page).not_to have_content("Change study mode for #{@provider.courses.first.name}")
  end

  def when_i_click_to_add_another_course
    click_link 'Add another course'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    when_i_choose_that_i_know_where_i_want_to_apply
  end

  def and_i_choose_the_multi_site_course_as_my_second_course_choice
    choose @provider.courses.second.name_and_code
    click_button t('continue')
  end

  def and_i_choose_the_full_time_study_mode
    choose 'Full time'
    click_button t('continue')
  end

  def and_i_choose_the_first_site
    choose @provider.courses.second.course_options.first.site.name
    click_button t('continue')
  end

  def and_i_should_see_the_first_site
    expect(page).to have_content(@provider.courses.second.course_options.first.site.name)
  end

  def and_i_should_see_a_change_location_link
    expect(page).to have_content("Change location for #{@provider.courses.second.name}")
  end

  def and_i_should_see_a_change_study_mode_link
    expect(page).to have_content("Change study mode for #{@provider.courses.second.name}")
  end

  def and_i_choose_the_single_site_course_as_my_third_course_choice
    choose @provider.courses.third.name_and_code
    click_button t('continue')
  end

  def and_i_should_see_another_change_study_mode_link
    expect(page).to have_content("Change study mode for #{@provider.courses.third.name}")
  end

  def and_i_should_not_see_another_change_location_link
    expect(page).not_to have_content("Change location for #{@provider.courses.third.name}")
  end

  def when_i_click_to_change_the_location_of_the_second_course_choice
    click_change_link "location for #{@provider.courses.second.name}"
  end

  def and_i_choose_the_second_site
    choose @provider.courses.second.course_options.second.site.name
    click_button t('continue')
  end

  def and_i_should_see_the_updated_site
    expect(page).to have_content(@provider.courses.second.course_options.second.site.name)
  end

  def when_i_click_to_change_the_study_mode_of_the_second_course_choice
    click_change_link "study mode for #{@provider.courses.second.name_and_code}"
  end

  def and_i_choose_part_time_study_mode
    choose 'Part time'
    click_button t('continue')
  end

  def then_i_should_see_the_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_am_asked_to_select_site
    expect(page).to have_content('Which location are you interested in?')
  end

  def and_i_choose_the_first_site_that_offers_part_time_study_mode
    choose @provider.courses.second.course_options.third.site.name
    click_button t('continue')
  end

  def and_i_should_see_the_updated_study_mode_for_the_second_choice
    second_chouce = page.all('.govuk-summary-list').to_a.second.text
    expect(second_chouce).to have_content("Full time or part time\nPart time")
  end

  def when_i_click_to_change_the_study_mode_of_the_third_course_choice
    click_change_link "study mode for #{@provider.courses.third.name_and_code}"
  end

  def and_i_should_see_the_updated_study_mode_for_the_third_choice
    third_choice = page.all('.govuk-summary-list').to_a.second.text

    expect(third_choice).to have_content("Full time or part time\nPart time")
  end

  def when_i_click_to_change_the_course_of_my_third_choice
    click_change_link "course choice for #{@provider.courses.third.name_and_code}"
  end

  def and_i_select_the_course_associated_with_my_second_choice
    choose @provider.courses.second.name_and_code
    click_button t('continue')
  end

  def then_i_am_told_that_i_have_already_added_that_course
    expect(page).to have_content t('errors.application_choices.already_added', course_name_and_code: @provider.courses.second.name_and_code)
  end
end

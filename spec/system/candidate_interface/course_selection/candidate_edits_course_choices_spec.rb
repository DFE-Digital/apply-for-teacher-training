require 'rails_helper'

RSpec.describe 'Candidate edits course choices' do
  include CandidateHelper
  include CourseOptionHelpers

  it 'Candidate edit their applications' do
    given_i_am_signed_in_with_one_login
    and_there_is_a_course_with_one_course_option
    and_there_is_a_course_with_multiple_course_options
    and_there_is_a_course_with_both_full_time_and_part_time_but_one_site

    when_i_visit_my_application_page
    and_i_click_on_course_choices

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_third_course_as_my_first_course_choice
    and_i_choose_full_time
    then_i_am_on_the_application_choice_review_page
    and_i_see_a_change_course_link

    when_i_click_to_change_the_course_for_the_first_course_choice
    and_i_choose_the_single_site_course_as_my_first_course_choice
    then_i_am_on_the_application_choice_review_page

    and_i_see_the_updated_change_course_link
    and_i_do_not_see_a_change_location_link
    and_i_do_not_see_a_change_full_time_or_part_time_link

    when_i_click_to_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_multi_site_course_as_my_second_course_choice
    and_i_choose_full_time
    and_i_choose_the_first_site
    then_i_am_on_the_application_choice_review_page

    then_i_am_on_the_application_choice_review_page
    and_i_see_the_first_site
    and_i_see_a_change_location_link
    and_i_see_a_change_full_time_or_part_time_link

    when_i_click_to_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_single_site_course_as_my_third_course_choice
    and_i_choose_full_time
    then_i_am_on_the_application_choice_review_page
    and_i_see_another_change_full_time_or_part_time_link
    and_i_do_not_see_another_change_location_link

    when_i_visit_my_application_page
    when_i_click_to_continue_my_second_course_choice
    when_i_click_to_change_the_location_of_the_second_course_choice
    and_i_choose_the_second_site
    then_i_am_on_the_application_choice_review_page
    and_i_see_the_updated_site

    when_i_click_to_change_full_time_or_part_time_of_the_second_course_choice
    and_i_choose_part_time
    and_i_am_asked_to_select_site
    and_i_choose_the_first_site_that_offers_part_time
    then_i_am_on_the_application_choice_review_page
    and_i_see_the_updated_full_time_or_part_time_section_for_the_second_choice

    when_i_visit_my_application_page
    and_i_click_to_continue_my_third_course_choice
    when_i_click_to_change_full_time_or_part_time_of_the_third_course_choice
    and_i_choose_part_time
    then_i_am_on_the_application_choice_review_page
    and_i_see_the_updated_full_time_or_part_time_section_for_the_third_choice
  end

  def and_there_is_a_course_with_one_course_option
    @provider = create(:provider, selectable_school: true)
    create(:course, :open, name: 'English', provider: @provider, study_mode: :full_time)

    course_option_for_provider(provider: @provider, course: @provider.courses.first)
  end

  def and_there_is_a_course_with_multiple_course_options
    create(:course, :open, :with_both_study_modes, name: 'Maths', provider: @provider)

    # Sites with full time study mode
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'full_time')

    # Sites with part time study mode
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'part_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.second, study_mode: 'part_time')
  end

  def and_there_is_a_course_with_both_full_time_and_part_time_but_one_site
    create(:course, :open, :with_both_study_modes, name: 'Entomology', provider: @provider)

    site = create(:site, provider: @provider)

    course_option_for_provider(provider: @provider, course: @provider.courses.third, site:, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site:, study_mode: 'part_time')
  end

  def when_i_visit_my_application_page
    visit candidate_interface_application_choices_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
  end

  def and_i_choose_a_provider
    select @provider.name_and_code
    click_link_or_button t('continue')
  end

  def and_i_choose_the_third_course_as_my_first_course_choice
    choose @provider.courses.third.name_and_code
    click_link_or_button t('continue')
  end

  def when_i_click_to_change_the_course_for_the_first_course_choice
    click_change_link "course for #{@provider.courses.third.name}"
  end

  def and_i_choose_the_single_site_course_as_my_first_course_choice
    choose @provider.courses.first.name_and_code
    click_link_or_button t('continue')
  end

  def and_i_see_a_change_course_link
    expect(page).to have_content("Change course for #{@provider.courses.third.name}")
  end

  def and_i_see_the_updated_change_course_link
    expect(page).to have_content("Change course for #{@provider.courses.first.name}")
  end

  def and_i_do_not_see_a_change_location_link
    expect(page).to have_no_content("Change location for #{@provider.courses.first.name}")
  end

  def and_i_do_not_see_a_change_full_time_or_part_time_link
    expect(page).to have_no_content("Change full time or part time for #{@provider.courses.first.name}")
  end

  def when_i_click_to_add_another_course
    and_i_click_on_course_choices
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    when_i_choose_that_i_know_where_i_want_to_apply
  end

  def and_i_choose_the_multi_site_course_as_my_second_course_choice
    choose @provider.courses.second.name_and_code
    click_link_or_button t('continue')
  end

  def and_i_choose_full_time
    choose 'Full time'
    click_link_or_button t('continue')
  end

  def and_i_choose_the_first_site
    choose @provider.courses.second.course_options.first.site.name
    click_link_or_button t('continue')
  end

  def and_i_see_the_first_site
    expect(page).to have_content(@provider.courses.second.course_options.first.site.name)
  end

  def and_i_see_a_change_location_link
    expect(page).to have_content("Change location for #{@provider.courses.second.name}")
  end

  def and_i_see_a_change_full_time_or_part_time_link
    expect(page).to have_content("Change full time or part time for #{@provider.courses.second.name}")
  end

  def and_i_choose_the_single_site_course_as_my_third_course_choice
    choose @provider.courses.third.name_and_code
    click_link_or_button t('continue')
  end

  def and_i_see_another_change_full_time_or_part_time_link
    expect(page).to have_content("Change full time or part time for #{@provider.courses.third.name}")
  end

  def and_i_do_not_see_another_change_location_link
    expect(page).to have_no_content("Change location for #{@provider.courses.third.name}")
  end

  def when_i_click_to_change_the_location_of_the_second_course_choice
    click_change_link "location for #{@provider.courses.second.name}"
  end

  def and_i_choose_the_second_site
    choose @provider.courses.second.course_options.second.site.name
    click_link_or_button t('continue')
  end

  def and_i_see_the_updated_site
    expect(page).to have_content(@provider.courses.second.course_options.second.site.name)
  end

  def when_i_click_to_change_full_time_or_part_time_of_the_second_course_choice
    click_change_link "full time or part time for #{@provider.courses.second.name_and_code}"
  end

  def and_i_choose_part_time
    choose 'Part time'
    click_link_or_button t('continue')
  end

  def and_i_am_asked_to_select_site
    expect(page).to have_content('School placement location')
    expect(page).to have_content('Which location are you interested in?')
  end

  def and_i_choose_the_first_site_that_offers_part_time
    choose @provider.courses.second.course_options.third.site.name
    click_link_or_button t('continue')
  end

  def and_i_see_the_updated_full_time_or_part_time_section_for_the_second_choice
    expect(page).to have_content('Full time or part time Part time')
  end

  def when_i_click_to_change_full_time_or_part_time_of_the_third_course_choice
    click_change_link "full time or part time for #{@provider.courses.third.name_and_code}"
  end

  def and_i_see_the_updated_full_time_or_part_time_section_for_the_third_choice
    expect(page).to have_content('Full time or part time Part time')
  end

  def when_i_click_to_continue_my_second_course_choice
    @application_choice = current_candidate.current_application.application_choices.second
    and_i_click_to_continue_my_application
  end

  def and_i_click_to_continue_my_third_course_choice
    @application_choice = current_candidate.current_application.application_choices.third
    and_i_click_to_continue_my_application
  end

  def then_i_am_on_the_application_choice_review_page
    expect(page).to have_current_path(/candidate\/application\/course-choices\/[0-9]*\/review/)
  end

  def and_i_click_to_continue_my_application
    page.find_link(nil, href: candidate_interface_course_choices_course_review_path(@application_choice.id)).click
  end
end

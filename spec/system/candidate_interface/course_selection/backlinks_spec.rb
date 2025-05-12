require 'rails_helper'

RSpec.describe 'Candidate edits course choices' do
  include CandidateHelper
  include CourseOptionHelpers

  it 'Candidate edit their applications' do
    given_i_am_signed_in_with_one_login
    and_there_is_a_course_with_one_course_option
    and_there_is_a_course_with_multiple_course_options
    and_there_is_a_course_with_both_study_modes_but_one_site

    when_i_visit_my_application_page
    and_i_click_on_course_choices

    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_the_third_course_as_my_first_course_choice
    and_i_choose_the_full_time_study_mode
    then_i_be_on_the_application_choice_review_page

    # back during form choice
    and_i_click_the_back_to_application_link
    then_i_see_the_application_page
  end

  def and_there_is_a_course_with_one_course_option
    @provider = create(:provider)
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

  def and_there_is_a_course_with_both_study_modes_but_one_site
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
    # find('div.autocomplete__wrapper').click
    # find('ul.autocomplete__menu li', text: @provider.name_and_code).click
    click_link_or_button t('continue')
  end

  def and_i_choose_the_third_course_as_my_first_course_choice
    choose @provider.courses.third.name_and_code
    click_link_or_button t('continue')
  end

  def when_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_see_a_back_link_to_study_mode_choice
    expect(page.current_url).to match(/\/candidate\/application\/continuous-applications\/provider\/\d+\/courses\/\d+/)
  end

  def and_i_choose_the_full_time_study_mode
    choose 'Full time'
    click_link_or_button t('continue')
  end

  def then_i_be_on_the_application_choice_review_page
    expect(page).to have_current_path(/candidate\/application\/course-choices\/[0-9]*\/review/)
  end

  def when_i_visit_the_review_page_directly
    page.visit(@review_url)
  end

  def and_i_view_the_application_
    click_link_or_button 'View application'
  end

  def and_i_click_the_back_to_application_link
    click_link_or_button 'Back to your application'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def and_i_save_the_review_page_url_for_later
    @review_url = page.current_url
  end
end

require 'rails_helper'

RSpec.describe 'Viewing cycle information' do
  include DfESignInHelpers

  scenario 'Support user can view courses for a provider' do
    given_i_am_signed_in_as_a_support_user
    and_courses_exist_in_the_database
    when_i_navigate_to_the_provider_courses_page
    then_i_see_the_provider_courses

    when_i_select_to_filter_by_courses_in_the_current_recruitment_cycle
    and_i_click_on_apply_filters
    then_i_see_only_courses_in_the_current_recruitment_cycle

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_courses_a_course_name
    and_i_click_on_apply_filters
    then_i_see_only_courses_with_that_course_name

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_courses_a_course_code
    and_i_click_on_apply_filters
    then_i_see_only_courses_with_that_course_code

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_open_courses
    and_i_click_on_apply_filters
    then_i_see_only_open_courses

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_closed_courses
    and_i_click_on_apply_filters
    then_i_see_only_closed_courses

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_unpublished_courses
    and_i_click_on_apply_filters
    then_i_see_only_unpublished_courses

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_hidden_courses
    and_i_click_on_apply_filters
    then_i_see_only_hidden_courses

    when_i_click_on_clear_filters
    then_i_see_all_courses_for_the_provider

    when_i_select_to_filter_by_open_courses
    and_i_select_to_filter_by_closed_courses
    and_i_click_on_apply_filters
    then_i_see_only_open_and_closed_courses
  end

private

  def and_courses_exist_in_the_database
    @provider = create(:provider)
    @open_course = create(:course, :open, provider: @provider, name: 'English', exposed_in_find: true)
    @closed_course = create(:course, :closed, provider: @provider, name: 'English', exposed_in_find: true)
    @unavailable_course = create(:course, :unavailable, provider: @provider, name: 'Science')
    @next_year_course = create(:course, :open, recruitment_cycle_year: RecruitmentCycleTimetable.next_year, provider: @provider, name: 'Mathematics', exposed_in_find: true)
    @another_provider_course = create(:course, :open, name: 'Art and design', exposed_in_find: true)
  end

  def when_i_navigate_to_the_provider_courses_page
    page.find('a', text: 'Providers', class: 'govuk-service-navigation__link').click
    click_on @provider.name
    page.find('a', text: 'Courses', class: 'govuk-link app-tab-navigation__link').click
  end

  def then_i_see_the_provider_courses
    expect(page).to have_current_path(support_interface_provider_courses_path(@provider))
    expect(page).to have_element(:h1, text: "Courses - #{@provider.name}", class: 'govuk-heading-l')
    and_i_see_all_courses_for_the_provider
  end

  def then_i_see_all_courses_for_the_provider
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end
  alias_method :and_i_see_all_courses_for_the_provider, :then_i_see_all_courses_for_the_provider

  def when_i_select_to_filter_by_courses_in_the_current_recruitment_cycle
    check RecruitmentCycleTimetable.current_year
  end

  def and_i_click_on_apply_filters
    click_on 'Apply filters'
  end

  def then_i_see_only_courses_in_the_current_recruitment_cycle
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_click_on_clear_filters
    click_on 'Clear filters'
  end

  def when_i_select_to_filter_by_courses_a_course_name
    check 'English'
  end

  def then_i_see_only_courses_with_that_course_name
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_select_to_filter_by_courses_a_course_code
    fill_in 'Course code', with: @open_course.code
  end

  def then_i_see_only_courses_with_that_course_code
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_no_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_select_to_filter_by_open_courses
    check 'Open'
  end

  def then_i_see_only_open_courses
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_no_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_select_to_filter_by_closed_courses
    check 'Closed by provider'
  end
  alias_method :and_i_select_to_filter_by_closed_courses, :when_i_select_to_filter_by_closed_courses

  def then_i_see_only_closed_courses
    within('table.govuk-table') do
      expect(page).to have_no_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_select_to_filter_by_unpublished_courses
    check 'Unpublished'
  end

  def then_i_see_only_unpublished_courses
    within('table.govuk-table') do
      expect(page).to have_no_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_no_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def when_i_select_to_filter_by_hidden_courses
    check 'Hidden in Find'
  end

  def then_i_see_only_hidden_courses
    within('table.govuk-table') do
      expect(page).to have_no_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_no_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end

  def then_i_see_only_open_and_closed_courses
    within('table.govuk-table') do
      expect(page).to have_text("#{@open_course.name} (#{@open_course.code})")
      expect(page).to have_text("#{@closed_course.name} (#{@closed_course.code})")
      expect(page).to have_no_text("#{@unavailable_course.name} (#{@unavailable_course.code})")
      expect(page).to have_no_text("#{@next_year_course.name} (#{@next_year_course.code})")
      expect(page).to have_no_text("#{@another_provider_course.name} (#{@another_provider_course.code})")
    end
  end
end
